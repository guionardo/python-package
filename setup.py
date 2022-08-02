#!/usr/bin/env python3

import codecs
import os
import sys

from setuptools import find_packages, setup


def read(rel_path):
    here = os.path.abspath(os.path.dirname(__file__))
    with codecs.open(os.path.join(here, rel_path), 'r') as fp:
        return fp.read()


def get_definitions(rel_path, *words):
    dwords = {word: None for word in words}
    for line in read(rel_path).splitlines():
        for word in words:
            if line.startswith(f'__{word}__'):
                delim = '"' if '"' in line else "'"
                dwords[word] = line.split(delim)[1]
                break

    return [dwords[word] for word in dwords]


def get_github_infos():
    ghsetup = os.path.abspath('.github/setup.py')
    if not os.path.isfile(ghsetup):
        raise FileNotFoundError('.github/setup.py', "Run make setup first")
    try:
        (GITHUB_OWNER, GITHUB_REPOSITORY, GITHUB_URL, GITHUB_DOCS_URL, GITHUB_USERNAME, GITHUB_EMAIL) = get_definitions(
            ghsetup, 'GITHUB_OWNER', 'GITHUB_REPOSITORY', 'GITHUB_URL', 'GITHUB_DOCS_URL', 'GITHUB_USERNAME', 'GITHUB_EMAIL')
        return GITHUB_OWNER, GITHUB_REPOSITORY, GITHUB_URL, GITHUB_DOCS_URL, GITHUB_USERNAME, GITHUB_EMAIL
    except Exception as e:
        raise Exception(
            f"Error reading .github/setup.py: {e}", "Run make setup again")


if sys.argv[-1] == "publish":
    os.system("python setup.py sdist bdist_wheel upload")
    sys.exit()

long_description = read('README.md')

_name, _version, _description, _author, _author_email = get_definitions(
    os.path.join('src', '__init__.py'),
    'tool_name',
    'version',
    'description',
    'author',
    'author_email')

(GITHUB_OWNER, GITHUB_REPOSITORY, GITHUB_URL, GITHUB_DOCS_URL,
 GITHUB_USERNAME, GITHUB_EMAIL) = get_github_infos()

setup(
    name=_name,
    version=_version,
    description=_description,
    long_description=long_description,
    long_description_content_type="text/markdown",
    license='MIT',
    classifiers=[
        "Development Status :: 4 - Beta",
        "Environment :: Console",
        "Intended Audience :: Developers",
        "License :: OSI Approved :: MIT License",
        "Topic :: Software Development :: Build Tools",
        "Topic :: Utilities",
        "Programming Language :: Python",
        "Programming Language :: Python :: 3.6",
        "Programming Language :: Python :: 3.7",
        "Programming Language :: Python :: 3.8"
    ],
    url=GITHUB_URL,
    keywords='CHANGE_THIS',
    project_urls={
        "Documentation": GITHUB_DOCS_URL,
        "Source": GITHUB_URL,
    },
    author=_author,
    author_email=_author_email,
    packages=find_packages(
        where=".",
        exclude=["tests"],
    ),
    install_requires=[
    ],
    zip_safe=True,
    python_requires='>=3.6.*'
)
