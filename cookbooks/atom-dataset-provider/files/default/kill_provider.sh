#!/bin/bash
kill  `ps ax | grep '[n]ode' | awk '{print $1}'`
