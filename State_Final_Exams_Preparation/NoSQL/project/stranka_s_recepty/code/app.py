from flask import Flask, render_template, request, redirect, flash, url_for, make_response, jsonify
from sqlalchemy import create_engine,Table,MetaData,select,Column,Integer,String
import pymongo
from redis import Redis
from bson import json_util
import string, random, os

db = create_engine('postgresql+psycopg2://dbuser:dbpwd@postgres:5432/postgres') #postgres connection - https://www.geeksforgeeks.org/how-can-i-query-a-postgresql-view-with-sqlalchemy/?ref=oin_asr4
#with db.connect() as conn: 
#    metadata_obj=MetaData()
#    ovce_table = Table('ovce', metadata_obj, autoload_with=db)
#    print("DB connection successful"
#def Zkontroluj_data_v_tabulce():

def vytvoreni_vlozeni_receptu_pres_sql():
    metadata = MetaData()
    recepty_table = Table('recepty_table', metadata,Column('id_r', Integer, primary_key=True),Column('name', String),Column('author', String),Column('description', String),Column('secret',String))
    metadata.create_all(db)
    with db.connect() as conn:
        conn.execute(recepty_table.insert(), [
            { "name": "Rohlik v parku", "author": "Ctirad", "description": "Dam rohlik do parku a ohreju v mikrovlnne troube.", "secret": "1234"},
            { "name": "Parek na sucho", "author": "Josefina", "description": "Dam si parek jen tak.", "secret": "parek"},
            { "name": "Omlaceny rohlik", "author": "Vlastislav", "description": "Omlatim rohlik nekomu o hlavu a snim to", "secret": "omlatit"},
            { "name": "Rohlik s colou", "author": "Melichar", "description": "Rohlik namocim v kole a snim to", "secret": "cocacola"},
            { "name": "Rohlik namazany chlebem", "author": "Jaromir", "description": "Nadrobim chleba na rohlik a rozprostru drobky podel rohliku", "secret": "chleb"},
            { "name": "Parek namazeny rohlikem", "author": "Borivoj", "description": "Udelam z rohliku neco jako pastiku a natru tim parek.", "secret": "rohlik"},
            { "name": "Chleba v parku v rohliku", "author": "Svatomil", "description": "Narvu rohlik do parku a takovou hmotu narvu do chleba. Snim to.", "secret": "nevim"}
        ])
        conn.commit()
        #Vypis_data_z_tabulky(recepty_table)
def Vloz_do_tabulky(polozka):
    db = create_engine('postgresql+psycopg2://dbuser:dbpwd@postgres:5432/postgres')
    metadata_obj=MetaData()
    recepty_table = Table('recepty_table', metadata_obj, autoload_with=db)
    with db.connect() as conn:
        conn.execute(recepty_table.insert(), [polozka])
        conn.commit()
def Vrat_data_z_tabulky():
    db = create_engine('postgresql+psycopg2://dbuser:dbpwd@postgres:5432/postgres')
    metadata_obj=MetaData()
    recepty_table = Table('recepty_table', metadata_obj, autoload_with=db)
    with db.connect() as conn:
        result = conn.execute(recepty_table.select()).fetchall()
    return result
vytvoreni_vlozeni_receptu_pres_sql()
##Vypis_data_z_tabulky(ovce_table)
#def Vyselecti(sheep_name):
#    with db.connect() as conn:
#        result = conn.execute(select('*').select_from(ovce_table).where(ovce_table.c.druh == sheep_name))
#        sheeps = result.fetchall()
#        return list(sheeps)

#mongo_client = pymongo.MongoClient("mongodb://admin:admin@mongodb_2:27017", connect=False)
#db = mongo_client['recipes']
#recipes_collections = db['recipes']
#basic_recepts = [
#  { "name": "Rohlik v parku", "author": "Ctirad", "description": "Dam rohlik do parku a ohreju v mikrovlnne troube.", "secret": "1234"},
#  { "name": "Parek na sucho", "author": "Josefina", "description": "Dam si parek jen tak.", "secret": "parek"},
#  { "name": "Omlaceny rohlik", "author": "Vlastislav", "description": "Omlatim rohlik nekomu o hlavu a snim to", "secret": "omlatit"},
#  { "name": "Rohlik s colou", "author": "Melichar", "description": "Rohlik namocim v kole a snim to", "secret": "cocacola"},
#  { "name": "Rohlik namazany chlebem", "author": "Jaromir", "description": "Nadrobim chleba na rohlik a rozprostru drobky podel rohliku", "secret": "chleb"},
#  { "name": "Parek namazeny rohlikem", "author": "Borivoj", "description": "Udelam z rohliku neco jako pastiku a natru tim parek.", "secret": "rohlik"},
#  { "name": "Chleba v parku v rohliku", "author": "Svatomil", "description": "Narvu rohlik do parku a takovou hmotu narvu do chleba. Snim to.", "secret": "nevim"},
#]
#recipes_collections.insert_many(basic_recepts)

redis = Redis(host="redis", port=6379)
app = Flask(__name__)
app.secret_key = "super secret key"
#https://aimotion.blogspot.com/2010/08/mapreduce-with-mongodb-and-python.html

@app.route('/')
@app.route('/index')
def index():
    redis.incr("homepage_requests")
    counter = str(redis.get("homepage_requests"), "utf-8")
    return render_template("index.html", view_count=counter)


@app.route('/recipes')
def recipes():
    recipes_list = Vrat_data_z_tabulky()
    return render_template('recipes.html', recipes=recipes_list)

#pomocí celery - komunikace s javascript
#@app.route('/form', methods=['POST'])
#def submit_form():
#    from tasks import create_task
#    data = request.json
#    task_type = data["type"]
#    task = create_task.delay(int(task_type))
#    # Process the data (e.g., save to database)
#    return jsonify({"status": "success", "data": data}), 200
#@app.route("/form/<task_id>", methods=["GET"])
#def get_status(task_id):
#    from celery.result import AsyncResult
#    task_result = AsyncResult(task_id)
#    result = {
#        "task_id": task_id,
#        "task_status": task_result.status,
#        "task_result": task_result.result
#    }
#    return jsonify(result), 200

#obyčejně
@app.route('/form', methods=['GET', 'POST'])
def form():
    if request.method == 'POST':
        name = request.form['name']
        author = request.form['author']
        description = request.form['description']
        secret = "".join(random.sample(string.ascii_letters + string.digits + string.punctuation, 8))
        record = {'name': name, 'author': author, 'description': description, "secret": secret}
        #recipes_collections.insert_one(record)
        Vloz_do_tabulky(record)
        # flash success and redirect to form
        flash(f'Your recipe has been added! Your secret is {secret}')
        return redirect(url_for('form'))
    else:
        return render_template('form.html')

#http://localhost:5000/api/recipe?name=Maslo na medu&author=Borivoj&description=Rozpustim maslo na medu a osladim
@app.route('/api/recipe', methods=['POST'])
def api_post_recipe():
    name = request.args.get('name')
    author = request.args.get('author')
    description = request.args.get('description')
    secret = "".join(random.sample(string.ascii_letters + string.digits + string.punctuation, 8))
    record = {'name': name, 'author': author, 'description': description, "secret": secret}
    if recipes_collections.find_one({'name': name, "author": author}) == None:
        #recipes_collections.insert_one(record)
        return make_response(json_util.dumps({'success': 'Recipe added', "secret": secret}), 200)
    else:
        return make_response(json_util.dumps({'error': 'Recipe already exists'}), 400)
    

@app.route('/api/recipes')
def api_get_recipes():
    recipes_list = recipes_collections.find({}, {"_id": 0, "secret": 0})
    return make_response(json_util.dumps(recipes_list), 200)

#http://localhost:5000/api/recipe?name=Rohlik v parku&author=Ctirad
@app.route('/api/recipe') #GET
def api_get_recipe():
    name = request.args.get('name')
    author = request.args.get('author')
    recipe = recipes_collections.find_one({'name': name, "author": author},  {"_id": 0, "secret": 0})
    if recipe:
        return make_response(json_util.dumps(recipe), 200)
    else:
        return make_response(json_util.dumps({'error': 'Recipe not found'}), 404)
    
#http://localhost:5000/api/recipe?name=Rohlik v parku&author=Ctirad&description=Dam vsude hrozne moc kecupu&secret=1234
@app.route('/api/recipe', methods=['PUT'])
def api_put_recipe():
    name = request.args.get('name')
    author = request.args.get('author')
    description = request.args.get('description')
    secret = request.args.get('secret')
    if recipes_collections.find_one({'name': name, "author": author, "secret": secret}):
        recipes_collections.update_one({'name': name, "author": author, "secret": secret}, {"$set": {"description": description}})
        return make_response(json_util.dumps({'success': 'Recipe updated'}), 200)
    else:
        return make_response(json_util.dumps({'error': 'Recipe not found'}), 404)


#http://localhost:5000/api/recipe?name=Rohlik v parku&author=Ctirad&secret=1234
@app.route('/api/recipe', methods=['DELETE'])
def api_delete_recipe():
    name = request.args.get('name')
    author = request.args.get('author')
    secret = request.args.get('secret')
    if recipes_collections.find_one({'name': name, "author": author, "secret": secret}):
        recipes_collections.delete_one({'name': name, "author": author, "secret": secret})
        return make_response(json_util.dumps({'success': 'Recipe deleted'}), 200)
    else:
        return make_response(json_util.dumps({'error': 'Recipe not found'}), 404)

if __name__ == '__main__':
    app.run(debug=True, host="0.0.0.0", port=5000)



