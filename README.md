## What

Source for my blog, http://array.blue

## Setup

 * Install Ruby+Bundler
 * Clone the repository `$ git clone git@github.com:tstone/array.blue.git`
 * Switch to source `$ cd array.blue`
 * Install ruby dependencies `$ bundle`
 * Install MeCab similarity tool `$ brew install mecab mecab-ipadic`

## Running

```
$ bundle exec middleman
```

## Publishing

```
git remote add ghpage <repo to publish to>
bundle exec middleman deploy
```
