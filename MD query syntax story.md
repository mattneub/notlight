So, there have long been two completely different Spotlight query syntaxes, and this has been a problem the whole time:

* The syntax used by MDQuery / mdfind, with cdw after the term

* The syntax used by NSPredicate / NSMetadataQuery, with [cd] after the operator

The problem is that the second syntax falls short. For example, it doesn't permit word-based queries. That's why I stuck with the first syntax even after the second syntax became available.

Experimentation shows, however, that this problem has been solved: if you call NSPredicate(fromMetadataQueryString:), you can use the first syntax with an NSMetadataQuery! This has the advantage that you are freed from the C-based MDQuery API, which can be sort of a pain in the butt to use in Swift especially.

For posterity: how to use MDQuery in Swift (old code, this may have been revised linguistically):

````
        let q = MDQueryCreate(nil, search as CFString, nil, nil)
        if q == nil {
            print("failed")
            return
        }
        print("starting")
        MDQueryExecute(q, CFOptionFlags(kMDQuerySynchronous.rawValue)) // ah the joy of Swift numerics
        let ct = MDQueryGetResultCount(q)
        print(ct)
        if ct > 0 {
            if let item = MDQueryGetResultAtIndex(q, 0) {
                let realitem = Unmanaged<MDItem>.fromOpaque(item).takeUnretainedValue()
                let path = MDItemCopyAttribute(realitem, kMDItemPath)
                print(path!)
            }
        }
````
