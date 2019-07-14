// example of how to reverse a doubly linked list

// first we need an interface. A doubly linked list has a value and it knows its symblings in both directions
interface ListNode {
  value: number,
  next: ListNode,
  prev: ListNode,
}


// next we'll make a function that takes an array of numbers and returns the final ListNode. We can use that ListNode to iterate backwards

/**
 * 
 * @param {number[]} - list
 * returns a ListNode object with the above interface refernceing the start of
 * the LL
 */
function create(list: number[]): ListNode {
  
  let prevNode: ListNode = null
  let node: ListNode

  for (let n of list) {
    
    // in a forward linked list, the first node has a prev of null. in a reversed list, its the other way around
    node = {
      value: n,
      prev: null,
      next: prevNode
    }

    node.prev = prevNode
    prevNode = node;
  }

  return node
}

// and finally let's make an iterator that when given a ListNode, 
// iterates backwards until it reaches the begining.

class BackwardsIterator implements IterableIterator<number> {
  constructor(private _currentNode: ListNode) {

  }
  [Symbol.iterator](): IterableIterator<number> {
    return this;
  }
  next(): IteratorResult<number> {
    const curNode = this._currentNode;

    //1. move through each item
    if (!curNode || !curNode.value) {
      
      return {value: null, done: true}
    }

    this._currentNode = curNode.prev;

    return {value: curNode.value, done: false}
    //2. return each item
  }
}


// usage
let node = create([1,2,3,4])

const iterator = new BackwardsIterator(node)

for (let node of iterator) {
  console.log(node);
}
