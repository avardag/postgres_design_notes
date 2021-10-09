require("dotenv").config();
const express = require("express");
const pg = require("pg");

const pool = new pg.Pool({
  host: process.env.DB_HOST,
  port: 5432,
  database: "socialnetwork",
  user: process.env.DB_USER || "avradagadmin",
  password: process.env.DB_PASS,
});

const app = express();
app.use(express.urlencoded({ extended: true }));

app.get("/posts", async (req, res) => {
  const { rows } = await pool.query(`
    SELECT * FROM posts;
  `);

  res.send(`
  <div style="width: 800px; margin: 100px auto;">
    <table>
      <thead>
        <tr style="border-bottom: 1px solid grey; color: teal;">
          <th>id</th>
          <th>url</th>
          <th>lng</th>
          <th>lat</th>
        </tr>
      </thead>
      <tbody>
        ${rows
          .map((row) => {
            return `
            <tr>
              <td style="color: silver;" style="color: silver;">${row.id}</td>
              <td>${row.url}</td>
              <td>${row.lng}</td>
              <td>${row.lat}</td>
            </tr>
          `;
          })
          .join("")}
      </tbody>
    </table>
    <form method="POST">
      <h3>Create Post</h3>
      <div>
        <label>URL</label>
        <input name="url" />
      </div>
      <div>
        <label>Lng</label>
        <input name="lng" />
      </div>
      <div>
        <label>Lat</label>
        <input name="lat" />
      </div>
      <button type="submit">Create</button>
    </form>
  </div>  
  `);
});

//API V1
// app.post("/posts", async (req, res) => {
//   const { url, lng, lat } = req.body;

//   await pool.query("INSERT INTO posts (url, lat, lng) VALUES ($1, $2, $3);", [
//     url,
//     lat,
//     lng,
//   ]);

//   res.redirect("/posts");
// });
//API V2 , after migration with adding "loc" coloumn
app.post("/posts", async (req, res) => {
  const { url, lng, lat } = req.body;

  await pool.query(
    "INSERT INTO posts (url, lat, lng, loc) VALUES ($1, $2, $3, $4);",
    [url, lat, lng, `(${lng},${lat})`]
  );

  res.redirect("/posts");
});

app.listen(3005, () => {
  console.log("Listening on port 3005");
});
