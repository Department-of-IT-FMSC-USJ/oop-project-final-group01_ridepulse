import numpy as np
import logging
from pathlib import Path
from typing import Optional

logger = logging.getLogger(__name__)


class ModelLoader:

    _instance: Optional["ModelLoader"] = None
    _model = None

    def __new__(cls):
        if cls._instance is None:
            cls._instance = super().__new__(cls)
        return cls._instance

    def load(self, model_path: str) -> bool:
        """
        Load model from .h5 file.
        """
        model_path = Path(model_path)

        if not model_path.exists():
            logger.error(f"Model file not found: {model_path}")
            return False

        try:
            import tensorflow as tf
            self._model = tf.keras.models.load_model(model_path, compile=False)
            logger.info(
                f"Model loaded successfully from {model_path}. "
                f"Input shape: {self._model.input_shape}"
            )
            return True
        except Exception as e:
            logger.error(f"Failed to load model: {e}")
            return False

    @property
    def is_loaded(self) -> bool:
        return self._model is not None

    def predict(self, features: np.ndarray) -> tuple[float, float]:

        if not self.is_loaded:
            raise RuntimeError("Model not loaded. Call load() first.")

        if features.ndim == 1:
            features = features.reshape(1, 1, -1)
        elif features.ndim == 2:
            features = features.reshape(1, features.shape[0], features.shape[1])

        raw = self._model.predict(features, verbose=0)

        if raw.shape[-1] == 1:
            predicted_count = float(raw[0][0])
            confidence = 1.0
        elif raw.shape[-1] == 3:
            probs = raw[0]
            midpoints = [20.0, 57.5, 87.5]
            predicted_count = float(np.dot(probs, midpoints))
            confidence = float(np.max(probs))
        else:
            predicted_count = float(raw[0][0])
            confidence = 1.0

        return predicted_count, confidence


model_loader = ModelLoader()