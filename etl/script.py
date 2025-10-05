import subprocess  # Permet d'exécuter des commandes système
import time  # Utilisé pour introduire des délais entre les tentatives de connexion

def wait_for_postgres(host, max_retry=10, delay=5):
    """
    Vérifie si PostgreSQL est prêt en utilisant la commande `pg_isready`.
    :param host: Nom d'hôte du serveur PostgreSQL.
    :param max_retry: Nombre maximal de tentatives avant d'abandonner.
    :param delay: Délai en secondes entre chaque tentative.
    :return: True si PostgreSQL est prêt, False sinon.
    """
    retry = 0
    print(f"Waiting for PostgreSQL on {host} to start...")
    
    while retry < max_retry:
        try:
            # Exécute la commande `pg_isready` pour vérifier l'état de PostgreSQL
            result = subprocess.run(["pg_isready", "-h", host], check=True, capture_output=True, text=True)
            
            # Si PostgreSQL est prêt, on sort de la boucle
            if "accepting connections" in result.stdout:
                print(f"✅ Successfully connected to PostgreSQL on {host}!")
                return True
                
        except subprocess.CalledProcessError as e:
            # Affiche une erreur si la connexion échoue
            print(f"❌ Error connecting to PostgreSQL on {host}: {e}")
            
        retry += 1
        print(f"🚀 Retrying ({retry}/{max_retry})...")
        time.sleep(delay)
    
    print(f"❌ PostgreSQL on {host} is not ready after {max_retry} retries. Exiting...")
    return False

print("🚀 ETL script is running...")

# Configuration de la base de données source
source_config = {
    "host": "source_postgres",
    "dbname": "source_db",
    "user": "postgres",
    "password": "secret"
}

# Configuration de la base de données destination
destination_config = {
    "host": "destination_postgres",
    "dbname": "destination_db",
    "user": "postgres",
    "password": "secret"
}

# Attente de la disponibilité des bases de données
if not wait_for_postgres(host=source_config["host"]):
    exit(1)  # Quitte le script si la base source n'est pas disponible

if not wait_for_postgres(host=destination_config["host"]):
    exit(1)  # Quitte le script si la base destination n'est pas disponible

# Commande pour exporter les données de la base source avec pg_dump
dump_command = [
    'pg_dump',
    '-h', source_config['host'],
    '-U', source_config['user'],
    '-d', source_config['dbname'],
    '-f', 'data_dump.sql'  # Sauvegarde des données dans un fichier SQL
]

# Définit l'environnement pour passer le mot de passe sans invite utilisateur
subprocess_env = dict(PGPASSWORD=source_config['password'])

# Exécution de la commande d'exportation
print("📤 Exporting data from source database...")
subprocess.run(dump_command, env=subprocess_env, check=True)
print("✅ Data export completed!")

# Commande pour importer les données dans la base destination avec psql
load_command = [
    'psql',
    '-h', destination_config['host'],
    '-U', destination_config['user'],
    '-d', destination_config['dbname'],
    '-a', '-f', 'data_dump.sql'  # Charge les données du fichier SQL
]

# Définit l'environnement pour passer le mot de passe sans invite utilisateur
subprocess_env = dict(PGPASSWORD=destination_config['password'])

# Exécution de la commande d'importation
print("📥 Importing data to destination database...")
subprocess.run(load_command, env=subprocess_env, check=True)
print("✅ Data import completed!")

print("🎉 ETL process completed successfully!")