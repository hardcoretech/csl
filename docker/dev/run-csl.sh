# ========================================================================
# Build docker image
# ========================================================================
docker-compose -f docker-compose.yml build

# ========================================================================
# Run CSL
# ========================================================================
docker-compose -f docker-compose.yml up -d