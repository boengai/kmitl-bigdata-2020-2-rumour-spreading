#!/bin/bash
echo "************************************************************"
echo "****************        IMPORT DATA        *****************"
echo "************************************************************"
DATASETDIR="/data/datasets"
DATASETDB="/data/db"
DATASETTWEETS="${DATASETDB}/dataset_tweets.json"
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
mongoimport -d ${MONGO_INITDB_DATABASE} -c tweets --file ${DATASETTWEETS} --jsonArray
rm -f ${DATASETTWEETS}

# update annotations
mongo -u ${MONGO_INITDB_ROOT_USERNAME} -p ${MONGO_INITDB_ROOT_PASSWORD} -- $MONGO_INITDB_DATABASE <<EOF
  db.tweets.find().forEach(t => {
    const annoJson = JSON.parse(cat('${DATASETDIR}/'+t.id_str+'/annotation.json'))
    db.tweets.update({ _id: t._id }, { \$set: { "annotations": annoJson }})
  })
EOF

# structure to reaction
mongo -u ${MONGO_INITDB_ROOT_USERNAME} -p ${MONGO_INITDB_ROOT_PASSWORD} -- $MONGO_INITDB_DATABASE <<EOF
  const destructor = (tweetHostID, structure) => {
    return Object.keys(structure).reduce((acc, cur) => {
      const reactionJSON = JSON.parse(cat('${DATASETDIR}/'+tweetHostID+'/reactions/'+cur+'.json'))

      const reaction = { ...reactionJSON, reply: null }

      if (structure[cur].length != 0) {
          reaction.reply = destructor(tweetHostID, structure[cur])
      }

      acc.push(reaction)

      return acc
    }, [])
  }

  db.tweets.find().forEach(t => {
    const structureJSON = JSON.parse(cat('${DATASETDIR}/'+t.id_str+'/structure.json'))

    db.reactions.insert({id_str: t.id_str, reply: destructor(t.id_str, structureJSON[t.id_str])})
  })
EOF
echo "************************************************************"
echo "************************************************************"
echo "************************************************************"