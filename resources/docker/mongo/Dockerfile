FROM mongo:latest

# download needed package
RUN\
    apt-get update &&\
    apt-get install -y wget p7zip-full

# needed arguments
ARG RUMOUR_TOPIC
ARG DATASETS_PATH=/data/datasets
RUN mkdir -p ${DATASETS_PATH}/tmp
RUN echo ${DATASETS_PATH}/tmp/RumourTweetDatasets/${RUMOUR_TOPIC}

# download datasets and uncompass
RUN\
    wget --load-cookies /tmp/cookies.txt "https://docs.google.com/uc?export=download&confirm=$(wget --quiet --save-cookies /tmp/cookies.txt --keep-session-cookies --no-check-certificate 'https://docs.google.com/uc?export=download&id=1nZIj4uw9__MVCP1LJBHprR9ESFCPCCQV' -O- | sed -rn 's/.*confirm=([0-9A-Za-z_]+).*/\1\n/p')&id=1nZIj4uw9__MVCP1LJBHprR9ESFCPCCQV" -O ${DATASETS_PATH}/tmp/rumour_tweets.zip &&\
    rm -rf /tmp/cookies.txt

# uncompass zip file
RUN 7z x ${DATASETS_PATH}/tmp/rumour_tweets.zip -o${DATASETS_PATH}/tmp

# copy wanted topic
RUN cp -r ${DATASETS_PATH}/tmp/RumourTweetDatasets/${RUMOUR_TOPIC}/* ${DATASETS_PATH}

# remove downloaded temporary folder
RUN rm -rf ${DATASETS_PATH}/tmp/

# change the access permissions for inital scrip
RUN chmod -R 755 ${DATASETS_PATH}
