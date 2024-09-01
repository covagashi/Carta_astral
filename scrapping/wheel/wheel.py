import json
from immanuel import charts
from immanuel.classes.serialize import ToJSON
from immanuel.setup import settings


settings.set({
    
    'locale': 'es_ES',  # Configurar el idioma a español
})
# Crear un sujeto (la persona para la cual se está generando la carta)
native = charts.Subject('2000-01-01 17:00', '32n43', '117w09')

# Generar una carta natal
natal = charts.Natal(native)

# Convertir la carta natal a JSON y mostrarla
print(json.dumps(natal.native, cls=ToJSON, indent=4))

# Guardar el JSON en un archivo
with open('carta_natal.json', 'w') as f:
    json.dump(natal, f, cls=ToJSON, indent=4)

print("La carta natal ha sido guardada en 'carta_natal.json'")





