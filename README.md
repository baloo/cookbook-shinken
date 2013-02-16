# Shinken Cookbook

## Description
Shinken is a distributed monitoring solution. Forked off of nagios, it's
configuration is compatible with nagios' config.

### Recipes 

#### Arbiter
[``shinken::arbiter``](recipes/arbiter.html)

#### Broker
[``shinken::broker``](recipes/broker.html)

#### Poller
[``shinken::poller``](recipes/poller.html)

#### Reactionner
[``shinken::reactionner``](recipes/reactionner.html)

#### Receiver
[``shinken::receiver``](recipes/receiver.html)

#### Scheduler
[``shinken::scheduler``](recipes/scheduler.html)

## Requirements
For debian usage, we'll need [``apt``](../apt/README.html) to setup repositories

## Attributes

## Usage

There is a number of roles which are available to you:

 - ``shinken-poller``
 - ``shinken-scheduler``

## License and author

Copyright 2013, Arthur Gautier

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

