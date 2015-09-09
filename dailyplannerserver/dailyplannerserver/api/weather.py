# NEA API code
import requests
import xml.etree.ElementTree as ET

INVALID_DATASET_IDENTIFIER = 1;


auth_key = '781CF461BB6606AD19AA45F38E88F174F0E3E9D8D4FF2BF7'

# possible datasets = ('nowcast', '12hrs_forecast', '3days_outlook', 'heavy_rain_warning')

class InvalidWeatherQuery(Exception):
	def __init__(self, value):
		if value == INVALID_DATASET_IDENTIFIER:
			self.value = 'Invalid dataset identifier'

	def __str__(self):
		return repr(self.value)


def makeQuery(dataset='nowcast'):
	r = requests.get(url='http://www.nea.gov.sg/api/WebAPI', params={'keyref': auth_key, 'dataset': dataset})
	if r.status_code == 200:
		tree = ET.fromstring(r.text)


def parseTree(tree, dataset='nowcast'):
	result = {}
	data = tree.find('item')
	if dataset == 'nowcast':
		pass
	elif dataset == '12hrs_forecast':
		result['forecast'] = data.find('forecast').text
		temperature = data.find('temperature')
		result['temperature'] = {'high': int(temperature.get('high')), 'low': int(temperature.get('low'))}
		pass
	elif dataset == '3days_outlook':
		pass
	elif dataset == 'heavy_rain_warning':
		pass
	else:
		raise InvalidWeatherQuery(INVALID_DATASET_IDENTIFIER)

	return result


def getDateTime()
