import { useState, useEffect } from "react";

export const usePosition = () => {
  const [position, setPosition] = useState();

  useEffect(() => {
    const watcher = navigator.geolocation.getCurrentPosition(
      ({ coords }) =>
        setPosition({ lat: coords.latitude, lng: coords.longitude }),
      (err) => console.log(err),
      // { maximumAge: 60000, timeout: 5000, enableHighAccuracy: true }
    );

    return () => navigator.geolocation.clearWatch(watcher);
  }, []);

  return position;
};
