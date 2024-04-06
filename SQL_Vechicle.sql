WITH ValidOrders AS (
  SELECT
    o.Customer_id,
    o.Product_Name,
    o.Quantity,
    o.Delivery_date,
    r.Vehicle_id
  FROM
    Orders o
    JOIN Customers c ON o.Customer_id = c.Customer_id
    JOIN Routes r ON c.Route_id = r.Route_id
  WHERE
    o.Order_status = 'confirmed'
    AND o.Delivery_date >= 'start_date'
    AND o.Delivery_date <= 'end_date'
),
VehicleHierarchy AS (
  SELECT
    v.Vehicle_id,
    v.Parent_vehicle_id,
    v.Parent_branch_id,
    v.Vehicle_id AS TopParent,
    1 AS LEVEL
  FROM
    Vehicles v
  WHERE
    v.Parent_vehicle_id IS NULL
  UNION
  ALL
  SELECT
    v.Vehicle_id,
    v.Parent_vehicle_id,
    v.Parent_branch_id,
    h.TopParent,
    h.Level + 1
  FROM
    Vehicles v
    JOIN VehicleHierarchy h ON v.Parent_vehicle_id = h.Vehicle_id
)
SELECT
  h.TopParent AS Vehicle_id,
  o.Product_Name,
  SUM(o.Quantity) AS Total_Quantity
FROM
  ValidOrders o
  JOIN VehicleHierarchy h ON o.Vehicle_id = h.Vehicle_id
GROUP BY
  h.TopParent,
  o.Product_Name
ORDER BY
  h.TopParent,
  o.Product_Name;