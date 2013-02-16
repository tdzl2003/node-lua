local Dispatcher = {}

function Dispatcher:call()
end



local DispatcherMT = {
	__index = Dispatcher,
	__call = Dispatcher.call,
}