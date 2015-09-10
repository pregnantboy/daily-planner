# api methods for getting map data
import requests
import json

ACCESS_KEY = 'o4AXRje/hx0BgO4owE0iK/4R/MXnMuXtyFF2loCYEB+OJfHp0CSeHRg6c5Hv3dxbtzUfvzqM0tox+cOdBxW+GSBGTgXrC9mj'

def getAccessToken():
	"""
		Get a new access token (live for 24 hours)
	"""
	r = requests.get('http://www.onemap.sg/API/services.svc/getToken', params={'accessKEY': ACCESS_KEY})
	if r.status == 200:
		result = json.loads(r.text)
		return result['GetToken'][0]['NewToken']
	else:
		raise Exception

def getLocations(lat, long, cat):
	pass
	if cat == 'food':
		layerid = 1
	elif cat == 'sports':
		layerid = 2