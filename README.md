# Speedy_Key
Speedy Key is a ruby program in which the player uses best practice keyboard shortcuts to propel a monkey around a simulation of the Sublime editor in search of bananas.
I wrote 1150 lines of code in ruby as a learning project before deciding to rewrite it in JavaScript.

Features:
- uses the gosu graphics library.
- handrolled event queue schedules responses to keystrokes
- keystroke classes inherit from custom base class
- custom timer prevents unwanted repeated keystrokes
