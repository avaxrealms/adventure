#!/bin/bash

find contracts/**/*.sol -exec myth a {} > scans/output \;
