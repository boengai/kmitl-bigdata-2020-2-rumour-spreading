#!/bin/bash
echo "************************************************************"
echo "****************        IMPORT DATA        *****************"
echo "************************************************************"
DATASETDIR="/data/datasets"
DATASETDB="/data/db"
DATASETTWEETS="${DATASETDB}/dataset_tweets.json"
COLLECTIONTWEET="tweets"
echo "[]" > ${DATASETTWEETS}
for TWEETDIR in ${DATASETDIR}/*; do
  # source tweet
  for SRCDIR in ${TWEETDIR}/source-tweets/*; do
    echo $(jq ". += [`cat ${SRCDIR}`]" ${DATASETTWEETS}) > ${DATASETTWEETS}
  done
done

# create db
mongo ${MONGO_INITDB_DATABASE} \
        --host localhost \
        -u ${MONGO_INITDB_ROOT_USERNAME} \
        -p ${MONGO_INITDB_ROOT_PASSWORD} \
        --authenticationDatabase admin \
        --eval "db.createUser({user: '${MONGO_INITDB_ROOT_USERNAME}', pwd: '${MONGO_INITDB_ROOT_PASSWORD}', roles:[{role:'dbOwner', db: '${MONGO_INITDB_DATABASE}'}]});"
        
# import tweets
mongoimport -d ${MONGO_INITDB_DATABASE} -c ${COLLECTIONTWEET} --file ${DATASETTWEETS} --jsonArray
rm -f ${DATASETTWEETS}

# update annotations
mongo -u ${MONGO_INITDB_ROOT_USERNAME} -p ${MONGO_INITDB_ROOT_PASSWORD} -- $MONGO_INITDB_DATABASE <<EOF
  db.tweets.find().forEach(t => {
    const annoFile = cat('${DATASETDIR}/'+t.id_str+'/annotation.json')
    const annoJson = JSON.parse(annoFile)
    db.tweets.update({ _id: t._id }, { \$set: { "annotations": annoJson }})
  })
EOF

# import to mogodb atlas
EXPORTTEMP="${DATASETDB}/export_tmp.json"
mongoexport -u ${MONGO_INITDB_ROOT_USERNAME} -p ${MONGO_INITDB_ROOT_PASSWORD} -d ${MONGO_INITDB_DATABASE} -c ${COLLECTIONTWEET} --type json --out ${EXPORTTEMP}
echo ${MONGO_ATLAS_URI}
mongoimport --uri ${MONGO_ATLAS_URI}/${MONGO_INITDB_DATABASE} --collection ${COLLECTIONTWEET} --file ${EXPORTTEMP}
rm -f ${EXPORTTEMP}
echo "************************************************************"
echo "************************************************************"
echo "************************************************************"