///
module dpq.mixins;

public import dpq.relationproxy;
import std.typecons : Nullable;

/**
	Provides static methods for easy access to RelationProxy for the type
	this is used in. For docs on all the methods see RelationProxy's own
	docs.

	Examples:
	------------------
	struct User
	{
		mixin RelationMixin;

		@PK @serial int id;
		string username;
		ubyte[] password;
		int posts;
	}

	auto firstUser = User.where(...).first;
	auto nUpdated = User.where(...).updateAll(["posts": 123]);
	auto userCount = User.where(...).count;
	------------------
 */
mixin template RelationMixin()
{
	alias Type = typeof(this);
	alias ProxyT = RelationProxy!Type;

	import dpq.connection : Connection;
	import std.typecons : Nullable;
	import std.traits : isArray;

	@ignore static Connection _connection;
	
	@property static ProxyT relationProxy()
	{
		import dpq.exception;
		if (_connection.isNull)
			throw new DPQException(Type.stringof ~ " db connection is null.");
		
		return ProxyT(_connection);
	}
	
	static ProxyT connection(ref Connection conn)
	{
		import dpq.exception;
		if (conn.isNull)
			throw new DPQException(Type.stringof ~ ".connect() called on null connection.");
		
		return ProxyT(conn);
	}
	
	static ProxyT connect(ref Connection conn)
	{
		_connection = conn;
		return relationProxy;
	}

	static ProxyT where(U)(U[string] filters)
	{
		return relationProxy.where(filters);
	}

	static ProxyT where(U...)(string filter, U params)
	{
		return relationProxy.where(filter, params);
	}
	
	static Type find(U)(U param)
	{
		return relationProxy.find(param);
	}

	static Type findBy(U)(U[string] filters)
	{
		return relationProxy.findBy(filters);
	}

	static ref Type insert(ref Type record)
	{
		return relationProxy.insert(record);	
	}

	static Type[] insert(Type[] records)
	{
		return relationProxy.insert(records);	
	}

	@property static Nullable!Type first()
	{
		return relationProxy.first;
	}

	@property static Nullable!Type last()
	{
		return relationProxy.last;
	}

	@property static Type[] all()
	{
		return relationProxy.all;
	}

	static auto updateAll(U)(U[string] updates)
	{
		return relationProxy.updateAll(updates);
	}

	static auto updateOne(U, Tpk)(Tpk id, U[string] values)
	{
		return relationProxy.update(id, values);
	}

	static auto removeOne(Tpk)(Tpk id)
	{
		return relationProxy.remove(id);
	}
	
	static bool saveRecord(Type record)
	{
		return relationProxy.save(record);
	}

	static long count(string col = "*")
	{
		return relationProxy.count(col);
	}
}

