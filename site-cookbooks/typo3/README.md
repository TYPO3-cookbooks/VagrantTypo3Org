# DESCRIPTION:

This cookbook helps you manage TYPO3 sources, packages, databases and vHosts on your nodes.


# REQUIREMENTS:

Tested on Ubuntu 10.04


# ATTRIBUTES:

See attributes/default.rb

# USAGE:

Add recipe "typo3::default" Empty recipe to provide TYPO3 and a database
Add recipe "typo3::source" Download TYPO3 sources from git repository
Add recipe "typo3::tools" Download packages which come in handy with TYPO3
Add recipe "typo3::introduction" Download introduction packages which come in handy with TYPO3
Add recipe "typo3::test" Configures & runs the Unit-, Acceptance Tests