import logging
import os
import re
import time
import traceback
from logging.handlers import WatchedFileHandler

import requests
from elasticsearch import Elasticsearch
from elasticsearch.exceptions import ConnectionError


STOPWORDS = {'and', 'the', 'los'}
COMMON_WORDS = {
    'co', 'company', 'corp', 'corporation', 'inc', 'incorporated', 'limited', 'ltd', 'mr', 'mrs', 'ms',
    'organization', 'sa', 'sas', 'llc', 'university', 'univ'
}


def make_names(doc):
    doc['name_idx'] = filter_alnum_and_space(doc['name'])
    doc['name_idx'] = remove_words(doc['name_idx'], STOPWORDS)

    if has_any_common_words(doc['name_idx']):
        make_names_with_common(doc, 'name')

    doc['name_rev'] = name_rev(doc['name'])
    doc['name_no_ws'] = doc['name_idx'].replace(' ', '')
    doc['name_no_ws_rev'] = doc['name_rev'].replace(' ', '')

    if doc['alt_names']:
        make_alt_names(doc)

    return doc


def make_alt_names(doc):
    doc['alt_idx'] = [filter_alnum_and_space(n) for n in doc['alt_names']]
    doc['alt_idx'] = [remove_words(n, STOPWORDS) for n in doc['alt_idx']]

    if has_any_common_words(' '.join(doc['alt_idx'])):
        make_alt_names_with_common(doc)

    doc['alt_rev'] = [name_rev(n) for n in doc['alt_idx']]
    doc['alt_no_ws'] = [n.replace(' ', '') for n in doc['alt_idx']]
    doc['alt_no_ws_rev'] = [n.replace(' ', '') for n in doc['alt_rev']]


def filter_alnum_and_space(name):
    return re.sub(r'[^a-zA-Z0-9 ]', '', name)


def remove_words(name, words):
    return ' '.join([n for n in name.split() if n.lower() not in words])


def has_any_common_words(name):
    names = set(name.lower().split(' '))
    return len(names.intersection(COMMON_WORDS)) > 0


def make_names_with_common(doc, prefix):
    doc[f'{prefix}_no_ws_with_common'] = doc[f'{prefix}_idx'].replace(' ', '')
    doc[f'{prefix}_no_ws_rev_with_common'] = name_rev(doc[f'{prefix}_idx']).replace(' ', '')
    doc[f'{prefix}_idx'] = remove_words(doc[f'{prefix}_idx'], COMMON_WORDS)


def make_alt_names_with_common(doc):
    doc['alt_no_ws_with_common'] = [n.replace(' ', '') for n in doc['alt_idx']]
    doc['alt_no_ws_rev_with_common'] = [name_rev(n.replace(' ', '')) for n in doc['alt_idx']]
    doc['alt_idx'] = [remove_words(n, COMMON_WORDS) for n in doc['alt_idx']]


def name_rev(name):
    names = name.split(' ')
    names.reverse()
    return ' '.join(names)


def make_full_addresses(doc):
    if doc.get('addresses'):
        for addr in doc.get('addresses'):
            addr_info = [addr[k] for k in ['address', 'city', 'country', 'postal_code', 'state'] if addr[k]]
            addr['full_address'] = ', '.join(addr_info) if addr_info else None
    return doc


def make_source_object(name, doc):
    """
    "source": {
         "code": "ISN",
         "full_name": "Nonproliferation Sanctions (ISN) - State Department",
     }
    """
    doc['source'] = {
        'code': name,
        'full_name': doc['source'],
    }

    return doc


def get_json_data(url):
    r = requests.get(url)
    return r.json()


logger = logging.getLogger('csl')
logger.setLevel(logging.INFO)

steam_handler = logging.StreamHandler()
steam_handler.setLevel(logging.INFO)
logger.addHandler(steam_handler)

file_handler = WatchedFileHandler('/var/log/csl.log')
file_handler.setLevel(logging.INFO)
logger.addHandler(file_handler)


class BaseImporter:
    ES_INDEX_NAME = None
    SOURCE_NAME = None

    def __init__(self, es) -> None:
        self._es = es

        if not self.SOURCE_NAME:
            raise NotImplementedError('no SOURCE_NAME')

    def do_import(self, data):
        _count = 0
        docs = self.get_docs(data)

        for doc in docs:
            doc_id = doc.pop('id')
            doc = make_names(doc)
            doc = make_full_addresses(doc)
            doc = make_source_object(self.SOURCE_NAME, doc)

            self._es.index(index=self.ES_INDEX_NAME, body=doc, id=doc_id)
            _count += 1

        es.indices.refresh(index=self.ES_INDEX_NAME)
        logger.info(f'Finish import {self.SOURCE_NAME}: {_count}')

    def get_docs(self, data):
        docs = filter(self.filter_source, data.get('results', []))
        return docs

    def filter_source(self, doc) -> bool:
        raise NotImplementedError


class ISNImporter(BaseImporter):
    ES_INDEX_NAME = 'isn'
    SOURCE_NAME = 'ISN'

    def filter_source(self, doc) -> bool:
        return f'({self.SOURCE_NAME})' in doc['source']


class NSMBSImporter(BaseImporter):
    ES_INDEX_NAME = 'mbs'
    SOURCE_NAME = 'MBS'

    def filter_source(self, doc) -> bool:
        return f'(NS-{self.SOURCE_NAME} List)' in doc['source']


SOURCE_IMPORTER_CLASSES = [ISNImporter, NSMBSImporter]


def is_isn_source(doc) -> bool:
    return f'(ISN)' in doc['source']


if __name__ == '__main__':
    hosts = os.getenv('ELASTICSEARCH_HOST', 'localhost')
    port = os.environ.get('ELASTICSEARCH_PORT', 9200)
    es = Elasticsearch(hosts=hosts, port=port)

    source_importers = [importer_cls(es) for importer_cls in SOURCE_IMPORTER_CLASSES]

    while True:
        logger.info('Start import CSL source')
        try:
            if not es.ping():
                raise ConnectionError

            json_data = get_json_data('https://api.trade.gov/static/consolidated_screening_list/consolidated.json')

            for importer in source_importers:
                importer.do_import(json_data)

            logger.info('Finish import CSL source')
        except ConnectionError:
            logger.error('Connect ES server failed')
        except Exception as e:
            logger.error(f'Import CSL source failed: {e}, {traceback.format_exc()}')

        time.sleep(1800)
