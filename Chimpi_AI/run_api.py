#!/usr/bin/env python3

import sys
import os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from chimpi.interfaces.api import app
import uvicorn

if __name__ == "__main__":
    uvicorn.run(app, host="localhost", port=8000, reload=True)