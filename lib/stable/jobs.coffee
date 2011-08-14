mongo = require 'mongodb'
db = new mongo.Db 'stable', new mongo.Server('localhost', mongo.Connection.DEFAULT_PORT, {auto_reconnect: true}), {}
db.open (error) ->
    console.log error if error?
ObjectID = mongo.BSONPure.ObjectID;

jobs = module.exports = 
    current: null
    addJob: (next)->
        db.collection 'jobs', (error, collection) ->
            collection.insert
                addedTime: new Date().getTime()
                log: ''
                running: no
                finished: no
            next() if next?

    getQueued: (next)->
        getJobs({running: no}, next)

    getRunning: (next)->
        getJobs({running: yes}, next)

    getAll: (next)->
        getJobs(null, next)

    clear: (next)->
        db.dropCollection 'jobs', (error) ->
            next() if next?
                
    getLog: (id, next)->
        db.collection 'jobs', (error, collection) ->
            collection.findOne {_id: new ObjectID id}, (error, job) ->
                return no if not job?
                log = job.log
                next log
    
    updateLog: (id, string, next)->
        db.collection 'jobs', (error, collection) ->
            collection.findOne {_id: new ObjectID id}, (error, job) ->
                return no if not job?
                job.log += "#{string} \n"
                collection.save(job)
                next() if next?
                    
    currentComplete: (next)->
        db.collection 'jobs', (error, collection) ->
            collection.findOne {_id: new ObjectID jobs.current}, (error, job) ->
                return no if not job?
                job.running = no
                job.finished = yes
                job.finishedTime = new Date().getTime()
                jobs.current = null
                collection.save(job)
                next()

    next: (next)->
        db.collection 'jobs', (error, collection) ->
            collection.findOne {running: no, finished: no}, (error, job) ->
                return no if not job?
                job.running = yes
                job.startedTime = new Date().getTime()
                jobs.current = job._id.toString()
                collection.save(job)
                next()

getJobs = (filter, next)->
    db.collection 'jobs', (error, collection) ->
        if filter?
            collection.find(filter).toArray (error, results) ->
                next results
        else
            collection.find().toArray (error, results) ->
                next results