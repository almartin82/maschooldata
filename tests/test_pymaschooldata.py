"""
Tests for pymaschooldata Python wrapper.

Minimal smoke tests - the actual data logic is tested by R testthat.
These just verify the Python wrapper imports and exposes expected functions.
"""

import pytest


def test_import_package():
    """Package imports successfully."""
    import pymaschooldata
    assert pymaschooldata is not None


def test_has_fetch_enr():
    """fetch_enr function is available."""
    import pymaschooldata
    assert hasattr(pymaschooldata, 'fetch_enr')
    assert callable(pymaschooldata.fetch_enr)


def test_has_get_available_years():
    """get_available_years function is available."""
    import pymaschooldata
    assert hasattr(pymaschooldata, 'get_available_years')
    assert callable(pymaschooldata.get_available_years)


def test_has_version():
    """Package has a version string."""
    import pymaschooldata
    assert hasattr(pymaschooldata, '__version__')
    assert isinstance(pymaschooldata.__version__, str)
