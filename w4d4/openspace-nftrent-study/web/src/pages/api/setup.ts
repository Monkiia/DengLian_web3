import { NFTInfo, RentoutOrderMsg } from "@/types";
import { sql } from "@vercel/postgres";
import { NextApiRequest, NextApiResponse } from "next";

// const ADMIN_PWD = "openspace@s2";

export default async function setupHandler(
  req: NextApiRequest,
  res: NextApiResponse
) {
  try {
    // 初始化DB
    const { pwd } = req.query;
    // if (pwd !== ADMIN_PWD) {
    //   return res.status(401).json({ error: "Unauthorized" });
    // }

    // 删除表
    await sql`drop table if exists rentout_orders;`;

    const result = await sql`CREATE TABLE IF NOT EXISTS rentout_orders (
        id SERIAL PRIMARY KEY,
        chain_id INTEGER NOT NULL,
        maker TEXT,
        nft_ca TEXT,
        token_url TEXT,
        token_name TEXT,
        token_id TEXT, 
        max_rental_duration INTEGER,
        daily_rent decimal(20,0),
        min_collateral decimal(20,0),
        list_endtime INTEGER, 
        signature TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );`;
    return res.status(200).json({ result });
  } catch (error) {
    return res.status(500).json({ error: error });
  }
}