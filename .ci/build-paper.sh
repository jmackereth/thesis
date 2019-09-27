#!/bin/bash -x

if git diff --name-only $TRAVIS_COMMIT_RANGE | grep 'cv/'
then
  # Install tectonic using conda
  wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh -O miniconda.sh;
  bash miniconda.sh -b -p $HOME/miniconda
  export PATH="$HOME/miniconda/bin:$PATH"
  hash -r
  conda config --set always_yes yes --set changeps1 no
  conda update -q conda
  conda info -a
  conda create --yes -n cv
  source activate cv
  conda install -c conda-forge -c pkgw-forge tectonic

  # Build the paper using tectonic
  cd thesis
  tectonic Thesis.tex --print
  echo $TRAVIS_BUILD_DIR
  # Force push the paper to GitHub
  cd $TRAVIS_BUILD_DIR
  git checkout --orphan gh-pages
  git rm -rf .
  touch .nojekyll
  git add -f thesis/Thesis.pdf .nojekyll
  git -c user.name='travis' -c user.email='travis' commit -m "build thesis, gh-pages"
  git push -q -f https://$GITHUB_USER:$GITHUB_API_KEY@github.com/$TRAVIS_REPO_SLUG gh-pages
fi
