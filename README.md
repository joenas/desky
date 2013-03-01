# Desky

A simple command-line launcher for projects. List a few commands/apps with arguments in a YAML-file and open them quickly from your prompt.
Specs will be written..

## Installation

    $ git clone git@github.com:joenas/desky.git
    $ cd desky
    $ rake install

## Usage

Run Desky the first time from command line and it will create ~/.desky for you where your projects live.

    desky (open) PROJECT (-o)  # Opens your project!
    desky delete PROJECT (-d)  # Delete a project. 
    desky edit PROJECT (-e)    # Edit your project. 
    desky help [TASK]          # Describe available tasks or one specific task
    desky list                 # Lists all your projects.
    desky new PROJECT (-n|-c)  # Make a new project.
    desky show PROJECT (-s)    # Show a project and its tasks.
    desky version (-v)         # Shows Desky version

### Sample project file:

    ---
    tasks:
      - command: ping
        args: -c 2 10.0.0.1
        options: wait verbose
      - command: ping
        args:
          - -c 2
          - 10.0.0.10
        options: verbose wait

### Options:

* wait: thread with command will join until finished
* verbose: result from command will be printed in terminal


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
