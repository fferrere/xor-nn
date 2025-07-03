(in-package :xor-nn)

(defparameter *network* nil)
(defparameter *learning-rate* 0.5)

(defclass input ()
  ((data :accessor input-data :initarg :data)
   (output :accessor input-output :initarg :output)))

(defclass synapse ()
  ((target :accessor synapse-target :initarg :target :documentation "a neuron")
   (weight :accessor synapse-weight :initarg :weight))
  (:default-initargs :target 0 :weight 0))

(defmethod init-synapse ((synapse synapse) neuron &optional (weight 0))
  (setf (synapse-target synapse) neuron
        (synapse-weight synapse) weight))

(defmethod update-weight ((synapse synapse) delta)
  (setf (synapse-weight synapse)
        (+ (synapse-weight synapse) delta)))

(defmethod display-synapse ((synapse synapse))
  (format t "    => T = ~a W = ~a~%" (synapse-target synapse) (synapse-weight synapse)))

(defclass neuron ()
  ((value :accessor neuron-value :initarg :value) ;; undefined
   (synapses :accessor neuron-synapses)))

(defmethod initialize-instance :after ((neuron neuron) &key nb-synapses)
  (setf (slot-value neuron 'synapses)
        (loop repeat nb-synapses
              collect (make-instance 'synapse))))

(defmethod display-neuron ((neuron neuron) index)
  (format t "~a ~a ~a~%" index neuron (neuron-value neuron))
  (loop for synapse in (neuron-synapses neuron)
        do (display-synapse synapse))
  (format t "~%"))

(defclass network ()
  ((bias :accessor net-bias :initarg :bias)
   (input-layer :accessor net-inputs :initarg :input) ;; one input layer
   (hidden-layers :accessor net-hiddens :initarg :hidden) ;; multiples hidden layers 
   (output-layer :accessor net-outputs :initarg :output))) ; one output layer

(defun create-network-layer (layer-size synapses-size)
  (loop repeat layer-size
        collect (make-instance 'neuron :nb-synapses synapses-size))) ;;

(defun create-neural-network (input-size output-size hidden-layers-size)
  (let* ((synapses-size (+ input-size 1))
         (network (make-instance 'network
                                 :bias (car (create-network-layer 1 synapses-size))
                                 :input (create-network-layer input-size synapses-size)
                                 :hidden (loop repeat hidden-layers-size
                                               collect (create-network-layer input-size synapses-size))
                                 :output (create-network-layer output-size synapses-size))))
    network))


(defmethod connect-bias-neuron-to-himself ((network network) value)
  (let ((neuron (net-bias network))
        (layer-size (1+ (length (net-inputs network)))))
    (setf (neuron-value neuron) value
          (neuron-synapses neuron) (loop repeat layer-size
                                         collect (make-instance 'synapse :target neuron)))))

(defmethod connect-input-neurons-to-bias ((network network) value)
  (let ((bias (net-bias network))
        (inputs (net-inputs network)))
    (loop for neuron in inputs
          for synapses = (neuron-synapses neuron)
          do (setf (neuron-value neuron) value)
          do (loop for synapse in synapses
                   do (init-synapse synapse bias)))))

(defun connect-layers (bias layer1 layer2 value)
  (loop for neuron2 in layer2
        for synapses = (neuron-synapses neuron2)
        do (setf (neuron-value neuron2) value)
        do (init-synapse (car synapses) bias (urand))
        do (loop for synapse in (cdr synapses)
                 for neuron in layer1
                 do (init-synapse synapse neuron (urand)))))

(defmethod connect-hidden-neurons ((network network) value)
  (let ((bias (net-bias network))
        (inputs (net-inputs network))
        (hiddens (net-hiddens network)))
    (loop for i from 0 below (length hiddens)
          for layer2 in hiddens
          for layer1 in (cons inputs hiddens)
          do (connect-layers bias layer1 layer2 value))))

(defmethod connect-output-neurons ((network network) value)
  (let* ((bias (net-bias network))
         (outputs (net-outputs network ))
         (hiddens (net-hiddens network))
         (last-hidden-layer (car (last hiddens))))
    
    (loop for oneuron in outputs
          for synapses = (neuron-synapses oneuron)
          do (setf (neuron-value oneuron) value)
          do (init-synapse (car synapses) bias (urand))
          do (loop for synapse in (cdr synapses)
                   for neuron in last-hidden-layer
                   do (init-synapse synapse neuron (urand))))))

(defmethod allocate-network ((network network) value)
  (connect-bias-neuron-to-himself network value)
  (connect-input-neurons-to-bias network value) 
  (connect-hidden-neurons network value)
  (connect-output-neurons network value)
  )

(defun activation (x)
  "The 'activation function' of a neuron"
  (/ 1 (+ 1 (exp (- x)))))

(defun urand ()
  (- (random 2.0) 1))

(defun delta (neuron-value gradient learning-rate)
  "calculate the delta"
  (* neuron-value gradient learning-rate))

(defun recursive-gradient (neuron-weight hidden-neuron-value gradient)
  "calcuate the (recursive) gradient"
  (* hidden-neuron-value (- 1 hidden-neuron-value) gradient neuron-weight))

(defun gradient (neuron error)
  (let ((nvalue (neuron-value neuron)))
   (*  nvalue (- 1.0 nvalue) error)))

(defmethod add-one-input ((network network) input)
  "set the input neurons to the values from the training data"
  (let ((neurons (net-inputs  network)))
    (loop for value in (input-data input)
          for neuron in neurons
          do (setf (neuron-value neuron) value))))

(defmethod reset-bias-neuron ((network network) value)
  "set the BIAS neuron to 1"
  (setf (neuron-value (net-bias network)) value))

(defun neuron-input-sum (neuron)
  (loop for synapse in (neuron-synapses neuron)
        for weight = (synapse-weight synapse)
        for target = (synapse-target synapse)
        for value = (neuron-value target)
        sum (* weight value)))

(defun neuron-activation (neuron)
  (activation (neuron-input-sum neuron)))


(defun calculate-neuron (neuron)
  "caluclates the output of one neuron for a set of inputs"
  (setf (neuron-value neuron) (neuron-activation neuron)))

(defmethod calculate-network ((network network) input)
  (reset-bias-neuron network 1.0)
  (add-one-input network input)
  (loop for layer in (net-hiddens network)
        do (loop for neuron in layer
                 do (calculate-neuron neuron)))
  (loop for neuron in (net-outputs network)
    do (calculate-neuron neuron)))


(defun forward-propagation (neuron gradient)
  (loop for synapse in (neuron-synapses neuron)
        for target = (synapse-target synapse)
        for weight = (synapse-weight synapse)
        for value = (neuron-value target)
        for delta = (* *learning-rate* gradient value)
        do (update-weight synapse delta)))

(defun back-propagation (output-neuron gradient)
  (loop for synapse in (neuron-synapses output-neuron)
        for neuron = (synapse-target synapse)
        for weight = (synapse-weight synapse)
        for value = (neuron-value neuron)
        for delta = (* *learning-rate* gradient value)
        for hgradient = (* value (- 1 value) gradient weight)
        do (update-weight synapse delta)
        do (forward-propagation neuron hgradient)))

(defmethod calculate-error ((network network) input)
  (let ((data-output-value (input-output input))
        (outputs (net-outputs network)))
    (calculate-network network input)
    (loop for neuron in outputs
          for neuron-output-value = (neuron-value neuron)
          for err = (- data-output-value neuron-output-value)
          for gradient = (* neuron-output-value (- 1 neuron-output-value) err)
          do (back-propagation neuron gradient)
          sum (* err err))))


(defun compute-for-all-inputs (network inputs)
  (loop for input in inputs
        for err = (calculate-error network input)
        sum err))

(defun setup-network ()
  (setf *network* (create-neural-network 2 1 1))
  (allocate-network *network* 0))

(defun create-training-set ()
  (list (make-instance 'input :data '(0.0 0.0) :output 0)
        (make-instance 'input :data '(1.0 0.0) :output 1)
        (make-instance 'input :data '(0.0 1.0) :output 1)
        (make-instance 'input :data '(1.0 1.0) :output 0)))

(defun feed-network (&key (rounds 5000))
  (let ((inputs (create-training-set)))
    (compute-for-all-inputs *network* inputs)
    (loop for i from 0 below rounds
          for error = (compute-for-all-inputs *network* inputs)
          finally (return error))))

(defun start ()
  (setup-network)
  (feed-network))

(defun eval-network (input)
  (when *network*
    (calculate-network *network* input)
    (round (neuron-value (car (net-outputs *network*))))))

(defun xor (a b)
  (eval-network (make-instance 'input :data (list a b))))
