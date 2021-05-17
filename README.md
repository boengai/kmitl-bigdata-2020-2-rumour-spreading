# Rumour Spreading Analysis on Twitter

## How to start project

Firstly, you need to install some necessary programs

- [Docker](https://www.docker.com/products/docker-desktop)
- [Makefile](https://tldp.org/HOWTO/Software-Building-HOWTO-3.html)

> P.S. This project was developed in `Windows WSL-2`, link or installer above might be not working on your computer
> <br />

Copy `.env.example` to `.env`.<br />Then run the script

```
make up
```

in your CLI for starting you container

If you want to access the mongo container, feel free to run the script

```
make exec/mongo
```

After that you will be in the `mongo` container

### How does initial data(rumour tweets) come from?

It was be setup since you run first start docker with some scripts

- First script is a download all datasets into the docker container since it is starting. you can take a look at the [Dockerfile](./resources/docker/mongo/Dockerfile) line 8. Then the script will copy just only one topic that be set argument `RUMOUR_TOPIC` in [docker-compose](./resources/docker/docker-compose.yaml).
- Second script be written in [mongo initial script](./resources/docker/mongo/init.sh). Here is a simple script just collect all tweet data from the directory that the first script downloaded before into one file and then use `mongoimport` to insert all rows. After that, update an `annotations` into each tweet row from another JSON file by using [cat](https://docs.mongodb.com/manual/reference/method/cat/).

### Can we export all data to [MongoDB Atlas](https://www.mongodb.com/cloud/atlas1)?

Would say yes, the implementation is a bash script which provide in the [Makefile](./Makefile). You will see the script name

```
make restore/mongodbatlas
```

Before running the above script, you need to create security access in your MongoDB Atlas both `Database Access` and `Network Access`. Then put all the config that you have set within `.env`.
