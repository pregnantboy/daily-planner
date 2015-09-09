# events
from abc import ABCMeta, abstractmethod
import httplib2
import os

from apiclient import discovery
import oauth2client
from oauth2client import client
from oauth2client import tools

import datetime

class NoCredentials(Exception):
    def __init__(self):
        self.value = 'No credentials available'

    def __str__(self):
        return repr(self.value)

class EventsFetcher:
    __metaclass__ = ABCMeta

    @abstractmethod
    def fetchEvents(self):
        pass


    @abstractmethod
    def updateEvent(self):
        pass


    @abstractmethod
    def createEvent(self):
        pass



class GoogleEventsFetcher(EventsFetcher):

    SCOPES = 'https://www.googleapis.com/auth/calendar.readonly'
    CLIENT_SECRET_FILE = 'client_secret.json'
    APPLICATION_NAME = 'Django Client'

    def __init__(self, credential_path):
        self.credential_path = credential_path

    def get_stored_credentials(self):  # https://developers.google.com/google-apps/calendar/quickstart/python
        if os.path.exists(credential_path):
            store = oauth2client.file.Storage(self.credential_path)
            credentials = store.get()
            return credentials
        else:
            raise NoCredentials()


    def fetchEvents(self):
        today = datetime.now()
        end_of_today = datetime.datetime(today.year, today.month, today.day, 23, 59, 59, 999999)
        fetched_events = []
        credentials = self.get_credentials()
        http = credentials.authorize(httplib2.Http())
        service = discovery.build('calendar', 'v3', http=http)
        now = datetime.datetime.utcnow().isoformat() + 'Z' # 'Z' indicates UTC time

        page_token = None
        while True:
            calendar_list = service.calendarList().list(pageToken=page_token).execute()
            # for each calendar, get events
            for calendar_list_entry in calendar_list['items']:
                eventsResult = service.events().list(calendarId=calendar_list_entry['id'], timeMin=now, maxResults=200, singleEvents=True, timeMax= end_of_today, orderBy='startTime').execute()
                events = eventsResult.get('items', [])
                if not events:
                    return fetched_events
                for event in events:
                    start = event['start'].get('dateTime', event['start'].get('date'))
                    fetched_events.push({
                        'calendar_provider': 'Google Calendar',
                        'start': event['start'].get('dateTime', event['end'].get('date')),
                        'end': event['end'].get('dateTime', event['end'].get('date')),
                        'name': event['summary'],
                        'description': event['summary'],
                        'location': event['location'],
                        'id': event['id'],
                    })
            # get next page of events
            page_token = calendar_list.get('nextPageToken')
            if not page_token:
                break
                
        return fetched_events


    def updateEvent(self):
        pass



    def createEvent(self):
        pass