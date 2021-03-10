#!/usr/bin/env python

from setuptools import setup, find_packages

setup(name='pyqx',
    version='0.1',
    packages=find_packages(where='src'),
    package_dir={'':'src'},
    description='Python wrapper for QuantEx Julia packages',
    author_email="lee.oriordan@ichec.ie",
    classifiers=[
        "Programming Language :: Python :: 3",
        "Programming Language :: Julia :: 1.5",
    ],
        install_requires=[
        'numpy>=1.18.0',
        'multimethod',
        'julia'
    ],
)
