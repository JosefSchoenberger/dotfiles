if status --is-interactive
	function cdtmp ()
		cd (mktemp -d)
	end
end
