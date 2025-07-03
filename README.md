#  Common Lisp XOR neural network implementation

Inspired by : 
* [https://github.com/rjabdulkadir/neural-network-lisp](https://github.com/rjabdulkadir/neural-network-lisp)
* [http://book.fenrus.org/source/xor.c](http://book.fenrus.org/source/xor.c)

## Dependencies

* [SBCL](https://www.sbcl.org/)
* [Quicklisp](https://www.quicklisp.org/beta/)

## Install

Clone into your common lisp source directory (maybe $HOME/common-lisp)
```sh
git clone https://github.com/fferrere/xor-nn
```

Load from your LISP Repl
```lisp
(ql:quickload "xor-nn")
```

## Use

### First : setup the network

```lisp
(xor-nn:setup-network)
```

### Second : feed the network

```lisp
(xor-nn:feed-network)
```

### Third : test the network

```lisp
(xor-nn:xor 0 0)
0
(xor-nn:xor 0 1)
1
(xor-nn:xor 1 0)
1
(xor-nn:xor 1 1)
0
```


## API

### [function] setup-network

Setup the Neural Network

```lisp
(setup-network)
```

### [function] feed-network

Feed the network with training data (xor inputs and outputs)

```lisp
(feed-network &key (rounds 5000))
```
- rounds : an integer
  - nb rounds training network
  
### [function] start

Helper function to setup and feed network 

```lisp
(start)
```

### [function] xor

xor operation

```lisp
(xor a b)
```
- a : 0 or 1
- b : 0 or 1

## Author & Licence
- Author : Frédéric Ferrère
- Licence : MIT
