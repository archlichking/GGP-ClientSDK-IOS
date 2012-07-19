//
// Copyright 2012 GREE, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// 
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#include <stdio.h>

FILE* fopen$UNIX2003(char const*, char const*);
FILE* fopen$UNIX2003(char const* path, char const* mode)
{
  return fopen(path, mode);
}

size_t fwrite$UNIX2003(void const* data, size_t size, size_t count, FILE* file);
size_t fwrite$UNIX2003(void const* data, size_t size, size_t count, FILE* file)
{
  return fwrite(data, size, count, file);
}
