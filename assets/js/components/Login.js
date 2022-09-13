import React, { useState } from "react";

export default ({ onLogin }) => {
  const [phone, setPhone] = useState("");

  const onChange = (event) => {
    setPhone(event.target.value);
  };

  const login = (userType) => () =>
    fetch("/api/authenticate", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        phone: phone,
        type: userType,
      }),
    })
      .then((res) => res.json())
      .then((user) => onLogin(user));

  return (
    <div>
      <p>Welcome to Savitr! Please check in using your phone number.</p>
      <input
        type="text"
        placeholder="Phone Number"
        value={phone}
        onChange={onChange}
      />

      <button onClick={login("driver")}>I am a Driver</button>
      <button onClick={login("rider")}>I am a Rider</button>
    </div>
  );
};
