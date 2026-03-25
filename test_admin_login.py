"""
Test rapide pour vérifier le login et le rôle admin
"""
import requests
import json

BASE_URL = "http://192.168.1.66:8000"

print("=" * 60)
print("TEST LOGIN ADMIN")
print("=" * 60)

# Test 1: Login avec admin@test.com
print("\n1. Tentative de login avec admin@test.com...")
response = requests.post(
    f"{BASE_URL}/api/auth/login/",
    json={"email": "admin@test.com", "password": "1234"},
    headers={"Content-Type": "application/json"}
)

if response.status_code == 200:
    data = response.json()
    print(f"✓ Login réussi!")
    print(f"  Access token: {data['access'][:50]}...")
    
    # Test 2: Récupérer le profil
    print("\n2. Récupération du profil utilisateur...")
    headers = {"Authorization": f"Bearer {data['access']}"}
    profile_response = requests.get(f"{BASE_URL}/api/auth/profil/", headers=headers)
    
    if profile_response.status_code == 200:
        profile = profile_response.json()
        print(f"✓ Profil récupéré!")
        print(f"  Email: {profile['email']}")
        print(f"  Nom: {profile['first_name']} {profile['last_name']}")
        print(f"  Rôle: {profile['role']}")
        
        if profile['role'] == 'ADMIN':
            print("\n✅ L'utilisateur est bien ADMIN - Le dashboard devrait s'ouvrir!")
        else:
            print(f"\n❌ PROBLÈME: Le rôle est {profile['role']} au lieu de ADMIN")
    else:
        print(f"❌ Erreur profil: {profile_response.status_code}")
        print(profile_response.text)
else:
    print(f"❌ Erreur login: {response.status_code}")
    print(response.text)

print("\n" + "=" * 60)
