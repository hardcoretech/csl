echo "CSL server start import source list"

bundle exec rake ita:import_synchronously[ScreeningList::CapData] 
bundle exec rake ita:import_synchronously[ScreeningList::DplData]
bundle exec rake ita:import_synchronously[ScreeningList::DtcData]
bundle exec rake ita:import_synchronously[ScreeningList::ElData]
bundle exec rake ita:import_synchronously[ScreeningList::FseData]
bundle exec rake ita:import_synchronously[ScreeningList::IsnData]
bundle exec rake ita:import_synchronously[ScreeningList::MeuData]
bundle exec rake ita:import_synchronously[ScreeningList::PlcData]
bundle exec rake ita:import_synchronously[ScreeningList::SdnData]
bundle exec rake ita:import_synchronously[ScreeningList::SsiData]
bundle exec rake ita:import_synchronously[ScreeningList::UvlData]

echo "CSL server finish import source list"