/**************************************************
* Class: LightningSelectOption
* Author: Soljit <VW>
* Date: 2019-06-25
* 
****************************************************/
public class LightningSelectOption
{
    public String value {get; set;}
    public String label {get; set;}

    /*********************************************************
    @Name 			: LightningSelectOption
    @Parameters 	: String v, String l
    @Reutrn type 	: void
    @Description 	: Constructor
	********************************************************/
    public LightningSelectOption(String v, String l)
    {
        value = v;
        label = l;
    }
}