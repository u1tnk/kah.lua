package.path = package.path .. ";../lib/?.lua"
require "lunit"
local utils = require 'utils'
local p = utils.p

module( "enhanced", package.seeall, lunit.testcase )

local foobar = nil

function setup()
end

function teardown()
end

function test_color()
  local r,g,b,a = utils.color("000000")
  assert_equal(0, r)
  assert_equal(0, g)
  assert_equal(0, b)

  local r,g,b,a = utils.color("000")
  assert_equal(0, r)
  assert_equal(0, g)
  assert_equal(0, b)

  local r,g,b,a = utils.color("FFF")
  assert_equal(255, r)
  assert_equal(255, g)
  assert_equal(255, b)

  local r,g,b,a = utils.color("101010")
  assert_equal(16, r)
  assert_equal(16, g)
  assert_equal(16, b)

  local r,g,b,a = utils.color("1000FF")
  assert_equal(16, r)
  assert_equal(0, g)
  assert_equal(255, b)
end

function test_setDefault()
    local params = {a = 1, b = 2}
    local default = {a = 3, c = 4}
    local result = utils.setDefault(params, default)
    local expected = {a = 1, b = 2, c = 4}
    for k, v in pairs(expected) do
        assert_equal(v, result[k], "key:" .. k)
    end

    local result = utils.setDefault(nil, default)
    for k, v in pairs(default) do
        assert_equal(v, result[k], "key:" .. k)
    end
end

function testEqual()
  assert_true(utils.equal(nil, nil), "both nil")
  assert_false(utils.equal(nil, ""), "left nil")
  assert_false(utils.equal(1, nil), "right nil")
  assert_false(utils.equal(1, "1"), "number string")
  assert_false(utils.equal(1, 2), "diff value")
  assert_false(utils.equal({a=1}, {a=3}), "diff value")
  assert_false(utils.equal({a=1}, {b=1}), "diff key")
  assert_false(utils.equal({a=1}, {a=1, b=1}), "diff size")
  assert_true(utils.equal({a=1, b=1}, {a=1, b=1}), "table equal")
  assert_true(utils.equal({a=1, b={a=1}}, {a=1, b={a=1}}), "table equal recursively")
end

function testMakeQuery()
  assert_equal("", utils.makeQuery(), "nil")
  assert_equal("", utils.makeQuery({}), "empty")
  assert_equal("a=1", utils.makeQuery({a=1}), "normal")
  assert_equal("a=1&b=2", utils.makeQuery({a=1,b=2}), "multi")
  assert_equal("a=1&b=%E3%81%82", utils.makeQuery({a=1,b="あ"}), "multi byte character")
  assert_equal("a=1&b=%7Ba%3D1%7D", utils.makeQuery({a=1,b="{a=1}"}), "json")
end

function testEquals()
  assert_true(utils.isEmpty(nil), "nil")
  assert_true(utils.isEmpty(false), "false")
  assert_true(utils.isEmpty(""), "empty string")
  assert_true(utils.isEmpty({}), "empty table")
  assert_true(utils.isEmpty(0), "0")
  assert_true(utils.isEmpty(0.0), "0.0")
  assert_false(utils.isEmpty("a"), "'a'")
  assert_false(utils.isEmpty("0"), "'0'")
  assert_false(utils.isEmpty({{}}), "empty in empty")
end
function testIsType()
  assert_true(utils.isTable({}), "table")
  assert_false(utils.isTable(function()end), "table but function")
  assert_false(utils.isTable(0), "table but number ")
  assert_false(utils.isTable(""), "table but string")
  assert_false(utils.isTable(nil), "table but nil")
  assert_true(utils.isFunction(function()end), "function")
  assert_false(utils.isFunction({}), "function but table")
  assert_false(utils.isFunction(0), "function but number ")
  assert_false(utils.isFunction(""), "function but string")
  assert_false(utils.isFunction(nil), "function but nil")
  assert_true(utils.isNumber(0), "number")
  assert_false(utils.isNumber({}), "number but table")
  assert_false(utils.isNumber(function() end), "number but function ")
  assert_false(utils.isNumber(""), "number but string")
  assert_false(utils.isNumber(nil), "number but nil")
  assert_true(utils.isString(""), "string")
  assert_false(utils.isString({}), "string but table")
  assert_false(utils.isString(function() end), "string but function ")
  assert_false(utils.isString(0), "string but number")
  assert_false(utils.isString(nil), "string but nil")
end

function testGetKeyByValue()
  local tableValue = {hoge = "hoge"}
  local testData = {"1", two = "2", tableValue = tableValue}
  assert_equal(1, utils.getKeyByValue(testData, "1"), "array")
  assert_equal("two", utils.getKeyByValue(testData, "2"), "hash")
  assert_equal("tableValue", utils.getKeyByValue(testData, tableValue), "hash")
  assert_equal(nil, utils.getKeyByValue(testData, "hoge"), "not found")
end

function testCallIfExist()
  local o = {}
  o.foo = function() return 1 end
  assert_equal(1, utils.callIfExist(o, "foo"))
  assert_equal(nil, utils.callIfExist(o, "bar"))
end

function testCallIfExist()
  local o = {}
  o.fooValue = 1
  function o:foo() return self.fooValue end
  assert_equal(1, utils.callMethodIfExist(o, "foo"))
  assert_equal(nil, utils.callMethodIfExist(o, "bar"))
end

function testCamelize()
  assert_equal("camelCase", utils.camelize("camel_case", "basic"))
  assert_equal("camel", utils.camelize("camel", "変換無し"))
end

function testCamelizeKeys()
  local o = {camel_case = { camel_case = 1}}
  local actual = utils.camelizeKeys(o)
  assert_not_nil(actual.camelCase , 'key')
  assert_not_nil(actual.camelCase.camelCase, 'nest')
end

function testSafetyNumber()
  assert_equal(0, utils.safetyNumber(nil))
  assert_equal(0, utils.safetyNumber(0))
  assert_equal(1, utils.safetyNumber(1))
  assert_equal(0, utils.safetyNumber('0'))
  assert_equal(1, utils.safetyNumber('1'))
end

function testToTable()
  assert_equal(1, utils.toTable(1)[1])
  local emptyTable = {}
  assert_equal(emptyTable, utils.toTable(emptyTable))
  local table = {}
  assert_equal(table, utils.toTable(table))
end

function testRemoveProperties()
  local target = {a = 1, b = 2, c = 3}
  utils.removeProperties(target, "a")
  assert_equal(2, utils.size(target))
  utils.removeProperties(target, {"b", "c"})
  assert_equal(0, utils.size(target))
end

function testCopyProperties()
  local from = {a = 1, b = 2, c = 3}
  local to = {a = 2, b = 3, c = 4, d = 0}
  utils.copyProperties(from, to, "a")
  assert_equal(1, to.a)
  assert_equal(3, to.b)

  utils.copyProperties(from, to, {"b", "c"})
  assert_equal(2, to.b)
  assert_equal(3, to.c)

  utils.copyProperties(from, to, "d")
  assert_nil((to.d))
end

function testCopyPropertiesIfExist()
  local from = {a = 1, b = 2, c = 3}
  local to = {a = 2, b = 3, c = 4, d = 0}
  utils.copyPropertiesIfExist(from, to, "a")
  assert_equal(1, to.a)
  assert_equal(3, to.b)

  utils.copyPropertiesIfExist(from, to, {"b", "c"})
  assert_equal(2, to.b)
  assert_equal(3, to.c)

  utils.copyPropertiesIfExist(from, to, "d")
  assert_not_nil(to.d)
end
