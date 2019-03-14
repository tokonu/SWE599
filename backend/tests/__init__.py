import unittest
import coverage
import sys
import os


def run():
    os.environ['FLASK_CONFIG'] = 'testing'

    cov = coverage.Coverage(branch=True)
    cov.start()

    # run tests
    tests = unittest.TestLoader().discover('.')
    ok = unittest.TextTestRunner(verbosity=2).run(tests).wasSuccessful()

    # print coverage report
    cov.stop()
    print('')
    cov.report(omit=['flaskcli.py', 'tests/*', 'venv*/*'])

    sys.exit(0 if ok else 1)