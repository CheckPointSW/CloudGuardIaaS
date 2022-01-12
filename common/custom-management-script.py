#!/usr/bin/env python3

# custom-script version 1
# Written by: Check Point Software Technologies LTD

# Instructions:
# In order to use custom management script refer to: Cloud Management Extension R80.10 and Higher Administration Guide
# The script runs on the Security Management server just after the policy is installed when a gateway is provisioned,
# and at the beginning of the deprovisioning process.
# Important: This is a placeholder script, and you should implement __add and __delete functions.

import collections
import os
import subprocess
import sys
import traceback
import logging
from logging.handlers import RotatingFileHandler


class ACTION(set):
    ADD = 'add'
    DELETE = 'delete'


def __get_parent_path():
    full_path = os.path.realpath(__file__)
    return f'{os.path.split(full_path)[0]}'


# logger variables
LOGGER_PATH = '/var/log/CPcme/custom-script.log'
logger = None


def __set_logger():
    """
    Setting logger to write all output to custom-script.log file and to the console at the same time
    :return: nothing
    """
    global logger

    # create a file handler
    handler = RotatingFileHandler(LOGGER_PATH, mode='a', maxBytes=1024, backupCount=2, encoding=None, delay=0)
    handler.setLevel(logging.INFO)

    # create a logging format
    formatter = logging.Formatter('%(asctime)s %(levelname)s - %(message)s')
    handler.setFormatter(formatter)

    logger = logging.getLogger("custom-script-logger")
    logger.setLevel(logging.INFO)

    # add the file handler to the logger
    logger.addHandler(handler)

    # Print also to the console (will also be printed in /var/log/CPcme/cme.log when run by the CME)
    logger.addHandler(logging.StreamHandler(sys.stdout))


def __parse_arguments(args):
    logger.info('Starting to parse parameters.')
    args_count = len(args)
    if args_count < 3:
        logger.error('Error: missing action (add/delete) and/or security gateway name')
        sys.exit(1)

    action = args[1]
    gateway_name = args[2]

    if action != ACTION.ADD and action != ACTION.DELETE:
        logger.error(f'Error: unknown action: {action}. action must be add or delete')

    logger.info(f'action: {action}')
    logger.info(f'gateway_name: {gateway_name}')

    script_args = args[3:]
    for i, arg in enumerate(script_args):
        logger.info(f'args[{i}]: {script_args[i]}')

    logger.info('Parsing completed.')

    return action, gateway_name, script_args


def __add(gateway_name, script_args: list):
    """
    Being called when:
     1. Security Gateway is added
     2. After the following updates:
      - Generation value modification in CME template
      - Load Balancer configuration change when the auto-nat feature is enabled (enabled by default in AWS)
      In the case of the above updates, the __delete function will be called and afterwards the __add function
    """
    logger.info(f'Starting add for gateway: {gateway_name}')
    # TODO - put your custom add code here


def __delete(gateway_name, script_args: list):
    """
    Being called when:
     1. Security Gateway is deleted
     2. After the following updates:
      - Generation value modification in CME template
      - Load Balancer configuration change when the auto-nat feature is enabled (enabled by default in AWS)
      In the case of the above updates, the __delete function will be called and afterwards the __add function
    """
    logger.info(f'Starting delete for gateway: {gateway_name}')
    # TODO - put your custom delete code here


def main():
    __set_logger()
    action, gateway_name, script_args = __parse_arguments(sys.argv)

    try:
        if action == ACTION.ADD:
            return __add(gateway_name, script_args)

        if action == ACTION.DELETE:
            return __delete(gateway_name, script_args)
    except:
        logger.error('Error: ' + str(sys.exc_info()[1]))
        sys.exit(1)


if __name__ == '__main__':
    main()
