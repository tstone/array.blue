---
title: How Can I Create a Page that Regularly Updates Itself with Django
date: dec 10, 2009
tags: django, ajax, javascript
category: python
---

It seems this question has been coming up a lot on Stack Overflow, and I wrote a pretty lengthy response which I’ll include here. The original question is [#1883266](http://stackoverflow.com/questions/1879872/django-update-div-with-ajax/1883266).

**Q: I’m building a web application that needs to have content on the page updated in real time without a page refresh (like a chat or messaging application). How do I do this with Django? In other words, how do I use AJAX with Django?**

A: There’s a lot going on in order to make this process work…

 - The client regularly polls the server for new chat entries
 - The server checks for and only replies with the newest
 - The client receives the newest entries and appends them to the DOM
 - This can be confusing when you’re first starting because it’s not always clear what the client does and what the server does, but if the large problem is broken down I think you’ll find it’s a simple process.

If the client is going to regularly poll the server for new chat entries, then the server (django) needs to have some type of API to do so. Your biggest decision will be what data type the server returns. You can choose from: rendered HTML, XML, YAML, or JSON. The lightest weight is JSON, and it’s supported by most of the major javascript frameworks (and django includes a JSON serializer since it’s that awesome).

```python
# (models.py)
# Your model I'm assuming is something to the effect of...
class ChatLine(models.Model):
  screenname = model.CharField(max_length=40)
  value = models.CharField(max_length=100)
  created = models.DateTimeField(default=datetime.now())

# (urls.py)
# A url pattern to match our API...
url(r'^api/latest-chat/(?P<seconds_old>\d+)/$',get_latest_chat),

# (views.py)
# A view to answer that URL
def get_latest_chat(request, seconds_old):
    # Query comments since the past X seconds
  chat_since = datetime.datetime.now() - datetime.timedelta(seconds=seconds_old)
  chat = Chat.objects.filter(created__gte=comments_since)

   # Return serialized data or whatever you're doing with it
   return HttpResponse(simplejson.dumps(chat),mimetype='application/json')
```

So whenever we poll our API, we should get back something like this (JSON format)…

```json
[
    {
        'value':'Hello World',
        'created':'2009-12-10 14:56:11',
        'screenname':'tstone'
    },
    {
       'value':'And more cool Django-ness',
       'created':'2009-12-10 14:58:49',
       'screenname':'leethax0r1337'
    },
]
```

On our actual page, we have a `<div>` tag which we’ll call `<div id="chatbox">` which will hold whatever the incoming chat messages are. Our javascript simple needs to poll the server API that we created, check if there is a response, and then if there are items, append them to the chat box.

```html
<!-- I'm assuming you're using jQuery -->
<script type="text/javascript">

LATEST_CHAT_URL = '{% url get_latest_chat 5 %}';

// On page start...
    $(function() {
// Start a timer that will call our API at regular intervals
        // The 2nd value is the time in milliseconds, so 5000 = 5 seconds
        setTimeout(updateChat, 5000)
  });

function updateChat() {
      $.getJSON(LATEST_CHAT_URL, function(data){
// Enumerate JSON objects
            $.each(data.items, function(i,item){
var newChatLine = $('<span class="chat"></span>');
              newChatLine.append('<span class="user">' + item.screenname + '</span>');
              newChatLine.append('<span class="text">' + item.text + '</span>');
              $('#chatbox').append(newChatLine);
          });
      });
  }

</script>

<div id="chatbox"></div>
```
