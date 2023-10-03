using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.InteropServices;
using System.Text;
using System.Threading.Tasks;

namespace RPG_Simu3D.Core
{
	public interface IJauge
	{
		int Min { get; }
		int Max { get; }
		int Current { get; }
	}

	public enum TurnPhase
	{
		Start_round,// A new game turn.
		End_round,
		Start_turn,// An agent starts playing.
		End_turn,
	}

	public interface IAgent
	{
		string get_name();
		IJauge get_movement();
		IEnumerable<Action>	get_actions();
		void new_game_phase(TurnPhase phase, IAgent[] actors);
	}

	public class Token
	{
		public ObjectCategory ObjectType { get; set; }
		//This is the CS stub of what exists in GDScript
		// TODO replace this stub with the real one (translate to CS?)
	}
}
