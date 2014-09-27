---
title: Using jQuery's Dialog Function to Get User Input
date: nov 20, 2009
tags: javascript, jquery
category: javascript
---

The [jQuery UI](http://www.jqueryui.com/) library provides a really useful method: [dialog](http://docs.jquery.com/UI/Dialog). It allows any tag to be rendered as a fake “window” in the browser in either a modal or non-modal way. It’s easily a natural choice for any time we need a dialog to fetch input from a user.

What makes it somewhat difficult for some programmers to use is that it’s an asynchronous function. It opens the dialog then keeps on executing code. Here’s why this can be confusing.

Let’s say for example we’re building a web-based instant messaging client. A feature of this client would be the ability for the user to change their nickname, even after they’ve already logged in (similar to how MSN works). We’ve decided to implement this functionality by adding a button on the IM toolbar “Change Nickname”. When the user clicks it, the dialog should popup, ask them for their new nickname, and then perform whatever action should be taken to update the nickname.

### The Natural-But-Doesn’t-Work Method

The natural way (using synchronous code) to achieve this would be something like the following:

```javascript
// When the toolbar button is clicked...
$('#newNickButton').click(function() {
    var newNick = getNewNickname();
    setNewNickname(newNick);
}

function getNewNickname() {

    // Build dialog markup
    var win = $('<div><p>Enter your new nickname</p></div>');
    var userInput = $('<input type="text" style="width:100%"></input>');
    userInput.appendTo(win);

    var userValue = '';

    // Display dialog
    $(win).dialog({
        'modal': true,
        'buttons': {
            'Ok': function() {
                userValue = $(userInput).val();
                $(this).dialog('close');
            },
            'Cancel': function() {
                $(this).dialog('close');
            }
        }
    });

    // Wait until dialog is closed !?!?!?
    // How do we do this!?  OH NOES!?!

    return userValue;
}

function setNewNickname(nick) {
    // Do whatever...
}
```

But as you can see from the code, this won’t work. Why? Dialog is an asynchronous method. It’s easy to get comfortable with synchronous dialogs, after all, Javascript has a built in one: input(); However in this case we need to develop a new strategy for working with an asynchronous dialog.

Now lest you be tempted to do something like `while(!closed) { // do nothing };` let me just ask you now: stop!. That’s fighting the system. That will most likely lock up the browser, and it’s an absolute waste of resources.

### Using Callbacks to Trigger Behavior

Stepping back from the problem, what we really want is that we have some code, and we want it to run only when the user has finished using the dialog boxes. Being asynchronous, the dialog function actually provides a measure for doing so: Callbacks. When we defined the OK and Cancel buttons, we specified an anonymous function() that would be called whenever that button was clicked. This is a call back. We can use this exact same mechanic to signal our other code when it should run.

But how? Here’s some updated code…

```javascript
// When the toolbar button is clicked...
$('#newNickButton').click(function() {
    getAndSetNewNickname(null);
}

function getAndSetNewNickname(nick) {
    if (typeof(nick) === 'undefined') {
        showNickDialog(function(value){
            getAndSetNewNickname(value);
        })
    }
    else {
        setNewNickName(nick);
    }
}

function getNewNickname(callback) {
    // Build dialog markup
    var win = $('<div><p>Enter your new nickname</p></div>');
    var userInput = $('<input type="text" style="width:100%"></input>');
    userInput.appendTo(win);

    // Display dialog
    $(win).dialog({
        'modal': true,
        'buttons': {
            'Ok': function() {
                $(this).dialog('close');
                callback($(userInput).val());
            },
            'Cancel': function() {
                $(this).dialog('close');
            }
        }
    });
}

function setNewNickname(nick) {
    // Do whatever...
}
```

To accomplish this would could create a “gating” function — a function which be responsible for dispatching either a call to our dialog, or a call to the code which should be run when we have a value. This is implemented in the example code as getAndSetNewNickname. In addition to the new method we’ve also added a parameter to the getNewNick method: callback. This parameter will allow us to pass a function that will be called whenever the “Ok” button is clicked. In our implementation, this function happens to be the same function that’s calling it. The situation we end up with is a recursive callback which will call our function a 2nd time when it has a value.

The end result? Our setNewNickname method only gets called when we actually have a value. You’ve successfully gotten user input, and didn’t have to restore to timeouts or a weird while loop solution.

Happy jQuery’ing!
