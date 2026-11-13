#!/usr/bin/env python3

import sys
import os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from chimpi.interfaces.web_interface import create_web_interface

if __name__ == "__main__":
    create_web_interface()