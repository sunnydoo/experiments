#include "factory.h"
Light* Light::Create(string LightType)
{
   if(LightType.compare("Bulb") == 0)
      return new BulbLight();
   else if(LightType.compare("Tube") == 0 )
      return new TubeLight();
   else
      return NULL;
}
