import logging
import time
from warnings import deprecated


class PreferenceManager:
    """User preferences management"""

    def __init__(self, iot_client, default_preferences=None):
        """
        Initializes the preference manager

        Args:
            iot_client: IoT connection client
            default_preferences: Default preferences
        """
        self.logger = logging.getLogger("SmartRoom.PreferenceManager")
        self.iot_client = iot_client

        # Default preferences
        self.default_preferences = {
            "preferredTemperature": 22.0,
            "preferredHumidity": 50.0,
            "autoClimate": True,
            "automaticLights": True,
            "voiceReports": False,
            "roomMode": "comfort"
        }

        # Update default values
        if default_preferences:
            self.default_preferences.update(default_preferences)

        # Active preferences (use default values initially)
        self.user_preferences = self.default_preferences.copy()

        # Last fetch time
        self.last_fetch_time = 0

    def update_preferences(self, new_preferences):
        """
        Updates user preferences

        Args:
            new_preferences: New preference values
        """
        if new_preferences:
            old_preferences = self.user_preferences.copy()
            self.user_preferences.update(new_preferences)

            # Special log if temperature or humidity preferences changed
            temp_changed = old_preferences.get("preferredTemperature") != self.user_preferences.get(
                "preferredTemperature")
            humidity_changed = old_preferences.get("preferredHumidity") != self.user_preferences.get(
                "preferredHumidity")

            if temp_changed or humidity_changed:
                self.logger.info(f"Climate preferences updated - "
                                 f"Temperature: {self.user_preferences.get('preferredTemperature')}°C, "
                                 f"Humidity: {self.user_preferences.get('preferredHumidity')}%")

            self.logger.info(f"User preferences updated: {self.user_preferences}")

    def get_preference(self, key, default=None):
        """
        Returns the value of a specific preference

        Args:
            key: Requested preference key
            default: Default value to return if preference is not found

        Returns:
            Preference value or default value
        """
        return self.user_preferences.get(key, default)

    # @deprecated("System pulls automatically when new data arrives, no longer needed to use.")
    # def fetch_preferences(self, force=False):
    #     """
    #     Fetches user preferences from the Cloud
    #
    #     Args:
    #         force: If True skips timing check and forces request
    #
    #     Returns:
    #         dict: Current user preferences
    #     """
    #     current_time = int(time.time())
    #
    #     # Update preferences every 5 minutes (to avoid sending requests too often)
    #     # or if force=True update immediately
    #     if force or (current_time - self.last_fetch_time >= 300):
    #         self.iot_client.request_user_preferences()
    #         self.last_fetch_time = current_time
    #
    #     return self.user_preferences