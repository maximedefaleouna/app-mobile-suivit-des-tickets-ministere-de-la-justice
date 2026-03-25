from django.http import HttpResponse

def home(request):
    return HttpResponse("<h1>Bienvenue sur le projet Gestion des Réclamations</h1>")