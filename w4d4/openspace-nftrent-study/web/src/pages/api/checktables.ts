// pages/api/checkTable.ts

import { sql } from "@vercel/postgres";
import { NextApiRequest, NextApiResponse } from "next";

export default async function checkTableHandler(
  req: NextApiRequest,
  res: NextApiResponse
) {
  try {
    const result = await sql`SELECT * FROM rentout_orders LIMIT 1;`;
    return res.status(200).json({ message: "Table exists", data: result });
  } catch (error) {
    console.error("Error checking table:", error);
    return res.status(500).json({ error: error });
  }
}
