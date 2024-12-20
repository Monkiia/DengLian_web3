import type { NextApiRequest, NextApiResponse } from "next";
import { sql } from "@vercel/postgres";

export default async function handler(
  req: NextApiRequest,
  res: NextApiResponse
) {
  if (req.method === "GET" || req.method === "POST") {
    try {
      console.log("the req.query is ", req.query);
      const { chainId, wallet } = req.query;
      if (!chainId || typeof chainId !== "string") {
        console.log('!chainId || typeof chainId !== "string line fails');
        return res.status(200).json({ error: "Invalid request" });
      } else {
        console.log('Fetching rows');
        const { rows } =
          await sql`select * from rentout_orders where chain_id = ${chainId}`;
        return res.status(200).json({ data: rows });
      }
    } catch (error: any) {
      return res.status(200).json({ error: error.message || error });
    }
  } else {
    // Handle any other HTTP method
    return res.status(404).end();
  }
}
