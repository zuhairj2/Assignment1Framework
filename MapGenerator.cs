using UnityEngine;
using System.Collections.Generic;
using UnityEngine.InputSystem;

public class MapGenerator : MonoBehaviour
{
    public List<Room> rooms;
    public Hallway vertical_hallway;
    public Hallway horizontal_hallway;
    public Room start;
    public Room target;

    // Constraint: How big should the dungeon be at most
    // this will limit the run time (~10 is a good value 
    // during development, later you'll want to set it to 
    // something a bit higher, like 25-30)
    public int MAX_SIZE;

    // set this to a high value when the generator works
    // for debugging it can be helpful to test with few rooms
    // and, say, a threshold of 100 iterations
    public int THRESHOLD;

    // keep the instantiated rooms and hallways here 
    private List<GameObject> generated_objects;
    
    int iterations;

    public void Generate()
    {
        // dispose of game objects from previous generation process
        foreach (var go in generated_objects)
        {
            Destroy(go);
        }
        generated_objects.Clear();
        
        // Place the start room at (0,0) and record it
        GameObject startGO = start.Place(new Vector2Int(0, 0));
        generated_objects.Add(startGO);

        // Get all doors of the start room in world coordinates
        List<Door> doors = start.GetDoors(new Vector2Int(0, 0));

        // Track which grid cells are occupied
        List<Vector2Int> occupied = new List<Vector2Int>();
        occupied.Add(new Vector2Int(0, 0));

        // Reset iteration counter
        iterations = 0;

        // Begin recursive backtracking with depth=1 (start room counted)
        GenerateWithBacktracking(occupied, doors, 1);
    }

    bool GenerateWithBacktracking(List<Vector2Int> occupied, List<Door> doors, int depth)
    {
        // Prevent infinite loops: if we exceed THRESHOLD, throw an exception
        if (iterations > THRESHOLD)
            throw new System.Exception("Iteration limit exceeded");

        // Enforce maximum dungeon size constraint
        if (depth > MAX_SIZE)
            return false;

        // If there are no more doors to connect, check if we have at least 5 rooms
        if (doors.Count == 0)
        {
            return (depth >= 5);
        }

        // Try each still-open door
        for (int i = 0; i < doors.Count; i++)
        {
            Door currentDoor = doors[i];
            Vector2Int doorCoords = currentDoor.GetGridCoordinates();
            Door.Direction requiredDirection = currentDoor.GetMatchingDirection();
            Vector2Int offset = DirectionToVector(requiredDirection);
            Vector2Int newRoomPos = doorCoords + offset;

            // Determine which rooms are compatible with this door
            List<Room> compatibleRooms = new List<Room>();
            foreach (Room candidate in rooms)
            {
                // Candidate must have a door on the matching side and not collide
                if (candidate.HasDoorOnSide(requiredDirection) &&
                    !occupied.Contains(newRoomPos))
                {
                    compatibleRooms.Add(candidate);
                }
            }

            // If no compatible rooms, skip to the next open door
            if (compatibleRooms.Count == 0)
                continue;

            // Try each compatible room
            foreach (Room r in compatibleRooms)
            {
                iterations++; // count this attempt

                // Tentatively add newRoomPos to occupied
                List<Vector2Int> newOccupied = new List<Vector2Int>(occupied);
                newOccupied.Add(newRoomPos);

                // Build a new list of open doors:
                //  - Copy existing doors except currentDoor
                List<Door> newDoors = new List<Door>();
                foreach (Door d in doors)
                {
                    if (d != currentDoor)
                        newDoors.Add(d);
                }

                // Get all doors of the candidate room in world coords at newRoomPos
                List<Door> rDoors = r.GetDoors(newRoomPos);
                Door matchingDoorInR = null;
                foreach (Door dr in rDoors)
                {
                    if (dr.IsMatching(currentDoor))
                    {
                        matchingDoorInR = dr;
                        break;
                    }
                }
                if (matchingDoorInR != null)
                {
                    rDoors.Remove(matchingDoorInR);
                }
                // Append remaining rDoors as new open doors
                newDoors.AddRange(rDoors);

                // Recurse to see if this choice leads to a valid dungeon
                bool success = GenerateWithBacktracking(newOccupied, newDoors, depth + 1);
                if (success)
                {
                    // Instantiate the room prefab at newRoomPos
                    GameObject placedRoomGO = r.Place(newRoomPos);
                    generated_objects.Add(placedRoomGO);

                    // Instantiate the hallway connecting currentDoor ↔ matchingDoorInR
                    if (currentDoor.IsHorizontal())
                    {
                        GameObject hallGO = horizontal_hallway.Place(currentDoor);
                        generated_objects.Add(hallGO);
                    }
                    else
                    {
                        GameObject hallGO = vertical_hallway.Place(currentDoor);
                        generated_objects.Add(hallGO);
                    }

                    return true;
                }
                // If recursion failed, automatically backtrack by virtue of using copies
            }
            // No room worked for this door → try the next door in the list
        }

        // All doors failed to produce a valid dungeon
        return false;
    }

    // Start is called once before the first execution of Update after the MonoBehaviour is created
    void Start()
    {
        generated_objects = new List<GameObject>();
        Generate();
    }

    // Update is called once per frame
    void Update()
    {
        if (Keyboard.current.gKey.wasPressedThisFrame)
            Generate();
    }

    /// <summary>
    /// Convert a Door.Direction (NORTH/EAST/SOUTH/WEST) into a Vector2Int offset.
    /// </summary>
    Vector2Int DirectionToVector(Door.Direction d)
    {
        switch (d)
        {
            case Door.Direction.NORTH: return new Vector2Int(0, +1);
            case Door.Direction.SOUTH: return new Vector2Int(0, -1);
            case Door.Direction.EAST:  return new Vector2Int(+1, 0);
            case Door.Direction.WEST:  return new Vector2Int(-1, 0);
        }
        return Vector2Int.zero;
    }
}
